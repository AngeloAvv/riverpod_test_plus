import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user.dart';

abstract interface class UserRepository {
  Future<User> fetchUser(int id);

  Future<User> rename(int id, String name);
}

/// The production implementation. Tests replace it through `overrides`.
class InMemoryUserRepository implements UserRepository {
  final _users = <int, User>{
    1: const User(id: 1, name: 'Angelo'),
    2: const User(id: 2, name: 'Remi'),
  };

  @override
  Future<User> fetchUser(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final user = _users[id];
    if (user == null) throw UserNotFound(id);
    return user;
  }

  @override
  Future<User> rename(int id, String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final user = await fetchUser(id);
    return _users[id] = user.copyWith(name: name);
  }
}

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => InMemoryUserRepository(),
  name: 'userRepositoryProvider',
);
