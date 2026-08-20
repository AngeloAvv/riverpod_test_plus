import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:riverpod_test_plus_example/todo/todo.dart';
import 'package:riverpod_test_plus_example/todo/todo_providers.dart';
import 'package:riverpod_test_plus_example/todo/todo_repository.dart';

import 'fakes.dart';

void main() {
  const todo = Todo(id: 1, title: 'Write a provider');
  late FakeTodoRepository repository;

  List<Override> withRepository() => [
    todoRepositoryProvider.overrideWithValue(repository),
  ];

  group('todoProvider', () {
    // A family member is just another provider: pass `todoProvider(id)`.
    riverpodTest<AsyncValue<Todo>>(
      'resolves the requested todo',
      setUp: () => repository = FakeTodoRepository(todos: [todo]),
      provider: todoProvider(1),
      overrides: withRepository,
      expect: () => [isLoading, isData(todo)],
    );

    riverpodTest<AsyncValue<Todo>>(
      'fails for an unknown id',
      setUp: () => repository = FakeTodoRepository(todos: [todo]),
      provider: todoProvider(404),
      overrides: withRepository,
      retry: noRetry,
      expect: () => [isLoading, isAsyncError<TodoNotFound>()],
    );

    riverpodTest<AsyncValue<Todo>>(
      'keeps family members independent',
      setUp: () => repository = FakeTodoRepository(
        todos: [
          todo,
          const Todo(id: 2, title: 'Test it'),
        ],
      ),
      provider: todoProvider(2),
      overrides: withRepository,
      expect: () => [isLoading, isData(const Todo(id: 2, title: 'Test it'))],
      verify: (ref) => expect(ref.exists(todoProvider(1)), isFalse),
    );
  });
}
