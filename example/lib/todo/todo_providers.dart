import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'todo.dart';
import 'todo_repository.dart';

/// A family: one provider instance per todo id.
final todoProvider = FutureProvider.family<Todo, int>(
  (ref, id) => ref.watch(todoRepositoryProvider).fetchTodo(id),
  name: 'todoProvider',
);

class TodoList extends AsyncNotifier<List<Todo>> {
  @override
  Future<List<Todo>> build() => ref.watch(todoRepositoryProvider).fetchTodos();

  Future<void> add(String title) async {
    final todo = await ref.read(todoRepositoryProvider).addTodo(title);
    state = AsyncData([...?state.value, todo]);
  }
}

final todoListProvider = AsyncNotifierProvider<TodoList, List<Todo>>(
  TodoList.new,
  name: 'todoListProvider',
);

/// Side-effect state: the UI watches it to show a spinner while adding.
final addTodoMutation = Mutation<void>(label: 'addTodo');

/// Runs [addTodoMutation] against any [MutationTarget] — a `WidgetRef` in the
/// UI, a `ProviderContainer` in tests.
Future<void> addTodo(MutationTarget target, String title) {
  return addTodoMutation.run(
    target,
    (tsx) => tsx.get(todoListProvider.notifier).add(title),
  );
}
