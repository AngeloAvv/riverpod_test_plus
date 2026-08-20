// `ProviderContainer.test` is annotated `@visibleForTesting`: this library is a
// testing library, and that constructor is exactly what it wants — a container
// disposed automatically at the end of the test.
//
// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';

import 'package:meta/meta.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart' as test;

import 'diff.dart';
import 'internal_bridge.dart';
import 'test_ref.dart';

/// Creates a test case that asserts on what [provider] emits.
///
/// One signature for every Riverpod target: `Provider`, `FutureProvider`,
/// `StreamProvider`, `NotifierProvider`, `AsyncNotifierProvider`,
/// `StreamNotifierProvider`, their families, `.future`/`.select` derivations and
/// `Mutation`s — anything that is a `ProviderListenable`.
///
/// ```dart
/// riverpodTest(
///   'increments the counter',
///   provider: counterProvider,
///   act: (ref) => ref.notifier(counterProvider).increment(),
///   expect: () => [0, 1],
/// );
/// ```
///
/// [setUp] runs before anything else and is the place to stub mocks. For setup
/// shared by several tests, prefer `setUp` from `package:test`.
///
/// [overrides] is a callback rather than a list because it is evaluated inside
/// the test body, after [setUp] — a plain list would be built while the tests
/// are being collected, before any mock exists.
///
/// [overrides] is also where a test starts the provider from a given state,
/// with Riverpod's own override methods: `overrideWithBuild` for a notifier
/// provider, `overrideWith` for a functional one.
///
/// ```dart
/// overrides: () => [counterProvider.overrideWithBuild((ref, self) => 9)],
/// ```
///
/// [observers] are installed on the test container.
///
/// [retry] overrides the container's retry policy. Riverpod retries failing
/// providers by default, which repeats the same failure in the sequence while a
/// test waits; pass [noRetry] when asserting on an error.
///
/// [act] interacts with the provider through a [TestRef]. An exception thrown
/// here does not fail the test — an API that records a failure and then
/// rethrows, as `Mutation.run` does, would otherwise blow up the very test
/// asserting on that failure. The exception is printed only if the test fails.
///
/// [wait] is awaited after [act], for debounces and other timers.
///
/// [fireImmediately] controls whether the initial state is recorded. Defaults to
/// `true`, so the emitted list starts from the state the provider builds to.
///
/// [skip] drops the first emissions before comparing against [expect].
///
/// [expect] returns what the provider is expected to emit — states **and
/// errors**, in the order they occurred. An async provider exposes a failure as
/// an `AsyncError` state; a synchronous one has no state to fail into, so the
/// error object itself takes its place in the sequence, and can be matched
/// either by value or with a matcher:
///
/// ```dart
/// expect: () => [1, 2, isA<RepositoryError>(), 4]
/// expect: () => [1, 2, const RepositoryError(), 4]
/// ```
///
/// [verify] runs after [expect] and receives the same [TestRef]; the container
/// is still alive, so providers can be read.
///
/// [tearDown] runs last. The container is disposed automatically afterwards.
///
/// [tags] is forwarded to `test`.
@isTest
void riverpodTest<StateT>(
  String description, {
  required ProviderListenable<StateT> provider,
  FutureOr<void> Function()? setUp,
  List<Override> Function()? overrides,
  List<ProviderObserver>? observers,
  Retry? retry,
  FutureOr<void> Function(TestRef ref)? act,
  Duration? wait,
  bool fireImmediately = true,
  int skip = 0,
  dynamic Function()? expect,
  dynamic Function(TestRef ref)? verify,
  FutureOr<void> Function()? tearDown,
  dynamic tags,
}) {
  test.test(description, () async {
    await testProvider<StateT>(
      provider: provider,
      setUp: setUp,
      overrides: overrides,
      observers: observers,
      retry: retry,
      act: act,
      wait: wait,
      fireImmediately: fireImmediately,
      skip: skip,
      expect: expect,
      verify: verify,
      tearDown: tearDown,
    );
  }, tags: tags);
}

/// Internal [riverpodTest] runner, only visible for testing.
///
/// This should never be used directly — use [riverpodTest] instead.
@visibleForTesting
Future<void> testProvider<StateT>({
  required ProviderListenable<StateT> provider,
  FutureOr<void> Function()? setUp,
  List<Override> Function()? overrides,
  List<ProviderObserver>? observers,
  Retry? retry,
  FutureOr<void> Function(TestRef ref)? act,
  Duration? wait,
  bool fireImmediately = true,
  int skip = 0,
  dynamic Function()? expect,
  dynamic Function(TestRef ref)? verify,
  FutureOr<void> Function()? tearDown,
}) async {
  var shallowEquality = false;

  try {
    await _runZonedGuarded(() async {
      await setUp?.call();

      final container = ProviderContainer.test(
        overrides: overrides?.call() ?? const [],
        observers: observers,
        retry: retry,
      );

      // States and errors share one list, in the order they happen: both come
      // from this single subscription, and `expect` is the only channel that
      // asserts on either. A provider whose state is an AsyncValue reports its
      // failure as an AsyncError state and never reaches onError; a synchronous
      // one has no state to fail into, so the error object takes its place.
      final emitted = <Object?>[];
      final subscription = container.listen<StateT>(
        provider,
        (previous, next) => emitted.add(next),
        fireImmediately: fireImmediately,
        onError: (error, stackTrace) {
          emitted.add(error);
          test.printOnFailure(
            'The provider under test emitted an error:\n$error\n$stackTrace',
          );
        },
      );

      final ref = TestRef(container);
      try {
        await act?.call(ref);
      } catch (error, stackTrace) {
        // Swallowed on purpose, and surfaced only when the test fails anyway:
        // see the `act` section of riverpodTest's documentation.
        test.printOnFailure('act threw:\n$error\n$stackTrace');
      }

      if (wait != null) await Future<void>.delayed(wait);
      await Future<void>.delayed(Duration.zero);
      subscription.close();

      if (expect != null) {
        final dynamic expected = await expect();
        final actual = emitted.skip(skip < 0 ? 0 : skip).toList();
        shallowEquality = '$actual' == '$expected';
        try {
          test.expect(actual, test.wrapMatcher(expected));
        } on test.TestFailure catch (e) {
          if (shallowEquality || expected is! List) rethrow;
          final diff = testDiff(expected: expected, actual: actual);
          throw test.TestFailure('${e.message}\n$diff');
        }
      }

      await verify?.call(ref);
      await tearDown?.call();
    });
  } catch (error) {
    if (shallowEquality && error is test.TestFailure) {
      throw test.TestFailure(
        """
${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of riverpodTest rather than concrete state instances.\n""",
      );
    }
    rethrow;
  }
}

Future<void> _runZonedGuarded(Future<void> Function() body) {
  final completer = Completer<void>();
  runZonedGuarded(
    () async {
      await body();
      if (!completer.isCompleted) completer.complete();
    },
    (error, stackTrace) {
      if (!completer.isCompleted) completer.completeError(error, stackTrace);
    },
  );
  return completer.future;
}
