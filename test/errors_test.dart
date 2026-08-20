import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('errors are part of the emitted sequence', () {
    riverpodTest<int>(
      'a synchronous failure takes the place of a state',
      provider: boomProvider,
      expect: () => [isA<Boom>()],
    );

    riverpodTest<int>(
      'the error can be matched by value',
      provider: boomProvider,
      expect: () => [const Boom()],
    );

    riverpodTest<int>(
      'states and errors interleave in the order they happen',
      provider: flakyProvider,
      act: (ref) async {
        final threshold = ref.notifier(thresholdProvider);
        threshold.update(2);
        // Rebuilds are scheduled, so let the failing one land before recovering.
        await Future<void>.delayed(Duration.zero);
        threshold.update(3);
      },
      expect: () => [10, isA<Boom>(), 30],
    );

    riverpodTest<AsyncValue<String>>(
      'an async failure stays a single AsyncError state',
      provider: userNameProvider,
      overrides: () => [
        userRepositoryProvider.overrideWithValue(FailingUserRepository()),
      ],
      retry: noRetry,
      wait: const Duration(milliseconds: 10),
      expect: () => [isLoading, isAsyncError<Boom>()],
    );
  });

  group('act', () {
    riverpodTest<int>(
      'does not fail the test when it throws',
      provider: counterProvider,
      act: (ref) {
        final counter = ref.notifier(counterProvider);
        counter.increment();
        counter.explode();
      },
      expect: () => [0, 1],
    );

    riverpodTest<int>(
      'what it threw is not part of the sequence',
      provider: counterProvider,
      act: (ref) => ref.notifier(counterProvider).explode(),
      expect: () => [0],
    );
  });
}
