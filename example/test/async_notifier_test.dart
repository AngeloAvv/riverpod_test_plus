import 'package:flutter_riverpod/flutter_riverpod.dart';
// `Override` lives in `misc.dart`; riverpod_test_plus does not re-export it.
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:riverpod_test_plus_example/user/user.dart';
import 'package:riverpod_test_plus_example/user/user_repository.dart';
import 'package:riverpod_test_plus_example/user/user_providers.dart';

import 'fakes.dart';

void main() {
  const user = User(id: 1, name: 'Angelo');
  late FakeUserRepository repository;

  List<Override> withRepository() => [
    userRepositoryProvider.overrideWithValue(repository),
  ];

  group('userProvider', () {
    riverpodTest<AsyncValue<User>>(
      'emits loading then the fetched user',
      setUp: () => repository = FakeUserRepository(user: user),
      provider: userProvider,
      overrides: withRepository,
      expect: () => [isLoading, isData(user)],
    );

    // `.future` is a `ProviderListenable<Future<User>>`, so the observed states
    // are futures: assert on them from `verify` instead of `expect`.
    riverpodTest<Future<User>>(
      'can be awaited through .future',
      setUp: () => repository = FakeUserRepository(user: user),
      provider: userProvider.future,
      overrides: withRepository,
      verify: (ref) async => expect(await ref.read(userProvider.future), user),
    );

    riverpodTest<AsyncValue<User>>(
      'surfaces the repository failure',
      setUp: () =>
          repository = FakeUserRepository(error: const UserNotFound(1)),
      provider: userProvider,
      overrides: withRepository,
      // Riverpod retries failing providers by default, which would emit extra
      // states while the test waits.
      retry: noRetry,
      expect: () => [isLoading, isAsyncError<UserNotFound>()],
    );
  });

  group('currentUserProvider', () {
    riverpodTest<AsyncValue<User>>(
      'renames the user',
      setUp: () => repository = FakeUserRepository(user: user),
      provider: currentUserProvider,
      overrides: withRepository,
      act: (ref) async {
        // Let the initial build settle, so the states below are the ones
        // `rename` itself produces.
        await ref.read(currentUserProvider.future);
        await ref.notifier(currentUserProvider).rename('Renamed');
      },
      expect: () => [
        isLoading,
        isData(user),
        isLoading,
        isData(user.copyWith(name: 'Renamed')),
      ],
    );

    riverpodTest<AsyncValue<User>>(
      'refetches on invalidate',
      setUp: () => repository = FakeUserRepository(user: user),
      provider: currentUserProvider,
      overrides: withRepository,
      act: (ref) async {
        await ref.read(currentUserProvider.future);
        ref.invalidate(currentUserProvider);
      },
      verify: (ref) => expect(repository.fetchCount, 2),
    );
  });
}
