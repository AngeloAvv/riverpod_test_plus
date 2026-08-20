import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user.dart';
import 'user_repository.dart';

/// A [FutureProvider] reading from an injected repository.
final userProvider = FutureProvider<User>(
  (ref) => ref.watch(userRepositoryProvider).fetchUser(1),
  name: 'userProvider',
);

class CurrentUser extends AsyncNotifier<User> {
  @override
  Future<User> build() => ref.watch(userRepositoryProvider).fetchUser(1);

  Future<void> rename(String name) async {
    final repository = ref.read(userRepositoryProvider);
    state = const AsyncLoading<User>();
    state = await AsyncValue.guard(() => repository.rename(1, name));
  }
}

final currentUserProvider = AsyncNotifierProvider<CurrentUser, User>(
  CurrentUser.new,
  name: 'currentUserProvider',
);
