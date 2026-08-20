import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo.dart';

abstract interface class TodoRepository {
  Future<List<Todo>> fetchTodos();

  Future<Todo> fetchTodo(int id);

  Future<Todo> addTodo(String title);
}

class InMemoryTodoRepository implements TodoRepository {
  final _todos = <Todo>[
    const Todo(id: 1, title: 'Write a provider'),
    const Todo(id: 2, title: 'Test it with riverpod_test_plus'),
  ];

  @override
  Future<List<Todo>> fetchTodos() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_todos);
  }

  @override
  Future<Todo> fetchTodo(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    for (final todo in _todos) {
      if (todo.id == id) return todo;
    }
    throw TodoNotFound(id);
  }

  @override
  Future<Todo> addTodo(String title) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final todo = Todo(id: _todos.length + 1, title: title);
    _todos.add(todo);
    return todo;
  }
}

final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => InMemoryTodoRepository(),
  name: 'todoRepositoryProvider',
);
