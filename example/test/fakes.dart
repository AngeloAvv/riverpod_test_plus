import 'package:riverpod_test_plus_example/todo/todo.dart';
import 'package:riverpod_test_plus_example/todo/todo_repository.dart';
import 'package:riverpod_test_plus_example/user/user.dart';
import 'package:riverpod_test_plus_example/user/user_repository.dart';

/// Hand written stubs — no mocking package involved.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({
    this.user = const User(id: 1, name: 'Angelo'),
    this.error,
  });

  final User user;
  final Object? error;

  int fetchCount = 0;

  @override
  Future<User> fetchUser(int id) async {
    fetchCount++;
    if (error case final error?) throw error;
    return user;
  }

  @override
  Future<User> rename(int id, String name) async {
    if (error case final error?) throw error;
    return user.copyWith(name: name);
  }
}

class FakeTodoRepository implements TodoRepository {
  FakeTodoRepository({List<Todo>? todos, this.addError})
    : todos = [
        ...todos ?? const [Todo(id: 1, title: 'Write a provider')],
      ];

  final List<Todo> todos;
  final Object? addError;

  @override
  Future<List<Todo>> fetchTodos() async => List.unmodifiable(todos);

  @override
  Future<Todo> fetchTodo(int id) async {
    for (final todo in todos) {
      if (todo.id == id) return todo;
    }
    throw TodoNotFound(id);
  }

  @override
  Future<Todo> addTodo(String title) async {
    if (addError case final error?) throw error;
    final todo = Todo(id: todos.length + 1, title: title);
    todos.add(todo);
    return todo;
  }
}
