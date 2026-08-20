import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

/// Every recipe documented in `docs/seeding.mdx`, kept honest by a test.
///
/// There is no `seed` parameter: a test starts a provider from a given state
/// with Riverpod's own override methods.
void main() {
  group('notifier providers — overrideWithBuild', () {
    riverpodTest<int>(
      'a sync notifier starts from the overridden build',
      provider: counterProvider,
      overrides: () => [counterProvider.overrideWithBuild((ref, self) => 9)],
      act: (ref) => ref.notifier(counterProvider).increment(),
      expect: () => [9, 10],
    );

    riverpodTest<AsyncValue<int>>(
      'an async notifier returning a value skips the loading state',
      provider: asyncCounterProvider,
      overrides: () => [
        asyncCounterProvider.overrideWithBuild((ref, self) => 5),
      ],
      act: (ref) => ref.notifier(asyncCounterProvider).increment(),
      expect: () => [isData(5), isData(6)],
    );

    riverpodTest<AsyncValue<int>>(
      'an async notifier can be held in loading',
      provider: asyncCounterProvider,
      overrides: () => [
        asyncCounterProvider.overrideWithBuild(
          (ref, self) => Completer<int>().future,
        ),
      ],
      expect: () => [isLoading],
    );

    riverpodTest<AsyncValue<int>>(
      'an async notifier can start in error',
      provider: asyncCounterProvider,
      overrides: () => [
        asyncCounterProvider.overrideWithBuild(
          (ref, self) => Future<int>.error(const Boom(), StackTrace.empty),
        ),
      ],
      retry: noRetry,
      wait: const Duration(milliseconds: 10),
      expect: () => [isLoading, isAsyncError<Boom>()],
    );

    riverpodTest<AsyncValue<int>>(
      'a stream notifier starts from a controller left open',
      provider: streamCounterProvider,
      overrides: () => [
        streamCounterProvider.overrideWithBuild((ref, self) {
          final controller = StreamController<int>();
          controller.add(7);
          ref.onDispose(controller.close);
          return controller.stream;
        }),
      ],
      wait: const Duration(milliseconds: 10),
      expect: () => [isLoading, isData(7)],
    );

    riverpodTest<int>(
      'the overridden build survives a rebuild',
      provider: scaledCounterProvider,
      overrides: () => [
        scaledCounterProvider.overrideWithBuild((ref, self) => 9),
      ],
      act: (ref) async {
        ref.notifier(scaledCounterProvider).increment();
        await Future<void>.delayed(Duration.zero);
        // Rebuilding runs the override again, not the original build — which is
        // also why the `ref.watch(thresholdProvider)` of the real build no
        // longer applies: changing the threshold rebuilds nothing.
        ref.notifier(thresholdProvider).update(3);
        ref.invalidate(scaledCounterProvider);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [9, 10, 9],
    );
  });

  group('families', () {
    riverpodTest<String>(
      'the applied family is what gets overridden',
      provider: labelProvider(7),
      overrides: () => [
        labelProvider(7).overrideWithBuild((ref, self) => 'seeded'),
      ],
      act: (ref) => ref.notifier(labelProvider(7)).shout(),
      expect: () => ['seeded', 'SEEDED'],
      verify: (ref) {
        expect(ref.read(labelProvider(2)), 'label-2');
      },
    );
  });

  group('functional providers — overrideWith', () {
    riverpodTest<String>(
      'a plain provider is replaced by the value',
      provider: greetingProvider,
      overrides: () => [greetingProvider.overrideWith((ref) => 'mocked')],
      expect: () => ['mocked'],
    );

    riverpodTest<AsyncValue<String>>(
      'a future provider returning a value skips the loading state',
      provider: userNameProvider,
      overrides: () => [userNameProvider.overrideWith((ref) => 'mocked')],
      expect: () => [isData('mocked')],
    );

    riverpodTest<AsyncValue<int>>(
      'a stream provider starts from a controller left open',
      provider: tickerProvider,
      overrides: () => [
        tickerProvider.overrideWith((ref) {
          final controller = StreamController<int>();
          controller.add(42);
          ref.onDispose(controller.close);
          return controller.stream;
        }),
      ],
      wait: const Duration(milliseconds: 10),
      expect: () => [isLoading, isData(42)],
    );

    riverpodTest<AsyncValue<String>>(
      'a future provider can start in error',
      provider: userNameProvider,
      overrides: () => [
        userNameProvider.overrideWith(
          (ref) => Future<String>.error(const Boom(), StackTrace.empty),
        ),
      ],
      retry: noRetry,
      wait: const Duration(milliseconds: 10),
      expect: () => [isLoading, isAsyncError<Boom>()],
    );
  });
}
