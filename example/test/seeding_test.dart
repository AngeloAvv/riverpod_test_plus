import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:riverpod_test_plus_example/counter/counter_provider.dart';
import 'package:riverpod_test_plus_example/user/user.dart';
import 'package:riverpod_test_plus_example/user/user_providers.dart';

/// Starting a test from a given state is done with Riverpod's own override
/// methods: `overrideWithBuild` for a notifier, `overrideWith` for a functional
/// provider. There is no dedicated parameter, and no dependency to mock — the
/// original `build` never runs.
void main() {
  const seeded = User(id: 1, name: 'Seeded');

  group('sync notifier', () {
    riverpodTest<int>(
      'starts from the overridden build',
      provider: counterProvider,
      overrides: () => [counterProvider.overrideWithBuild((ref, self) => 9)],
      act: (ref) => ref.notifier(counterProvider).increment(),
      expect: () => [9, 10],
    );
  });

  group('async notifier', () {
    riverpodTest<AsyncValue<User>>(
      'starts from a loaded user',
      provider: currentUserProvider,
      overrides: () => [
        currentUserProvider.overrideWithBuild((ref, self) => seeded),
      ],
      expect: () => [isData(seeded)],
    );

    riverpodTest<AsyncValue<User>>(
      'can be held in loading',
      provider: currentUserProvider,
      overrides: () => [
        currentUserProvider.overrideWithBuild(
          (ref, self) => Completer<User>().future,
        ),
      ],
      expect: () => [isLoading],
    );

    riverpodTest<AsyncValue<User>>(
      'can start in error',
      provider: currentUserProvider,
      overrides: () => [
        currentUserProvider.overrideWithBuild(
          (ref, self) =>
              Future<User>.error(const UserNotFound(1), StackTrace.empty),
        ),
      ],
      retry: noRetry,
      expect: () => [isLoading, isAsyncError<UserNotFound>()],
    );
  });
}
