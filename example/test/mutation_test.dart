import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:riverpod_test_plus_example/todo/todo.dart';
import 'package:riverpod_test_plus_example/todo/todo_providers.dart';
import 'package:riverpod_test_plus_example/todo/todo_repository.dart';

import 'fakes.dart';

void main() {
  late FakeTodoRepository repository;

  List<Override> withRepository() => [
    todoRepositoryProvider.overrideWithValue(repository),
  ];

  group('addTodoMutation', () {
    // A `Mutation` is a `ProviderListenable` of its own state.
    riverpodTest<MutationState<void>>(
      'goes idle -> pending -> success',
      setUp: () => repository = FakeTodoRepository(todos: const []),
      provider: addTodoMutation,
      overrides: withRepository,
      act: (ref) async {
        await ref.read(todoListProvider.future);
        await addTodo(ref, 'A new todo');
      },
      expect: () => [isIdle, isPending, isSuccess(null)],
      verify: (ref) => expect(ref.read(todoListProvider).value, [
        const Todo(id: 1, title: 'A new todo'),
      ]),
    );

    riverpodTest<MutationState<void>>(
      'goes idle -> pending -> error',
      setUp: () => repository = FakeTodoRepository(
        todos: const [],
        addError: StateError('offline'),
      ),
      provider: addTodoMutation,
      overrides: withRepository,
      act: (ref) async {
        await ref.read(todoListProvider.future);
        await addTodo(ref, 'A new todo');
      },
      expect: () => [isIdle, isPending, isMutationError<StateError>()],
    );
  });
}
