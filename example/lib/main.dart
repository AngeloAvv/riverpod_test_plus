import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'counter/counter_provider.dart';
import 'greeting/greeting_provider.dart';
import 'ticker/ticker_provider.dart';
import 'todo/todo.dart';
import 'todo/todo_providers.dart';
import 'user/user.dart';
import 'user/user_providers.dart';

void main() {
  runApp(const ProviderScope(child: ExampleApp()));
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'riverpod_test_plus',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(ref.watch(greetingProvider))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          CounterSection(),
          Divider(height: 32),
          UserSection(),
          Divider(height: 32),
          TickerSection(),
          Divider(height: 32),
          TodoSection(),
        ],
      ),
    );
  }
}

class CounterSection extends ConsumerWidget {
  const CounterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Row(
      children: [
        const Expanded(child: Text('Counter')),
        IconButton(
          key: const Key('decrement'),
          onPressed: ref.read(counterProvider.notifier).decrement,
          icon: const Icon(Icons.remove),
        ),
        Text('$count', key: const Key('count')),
        IconButton(
          key: const Key('increment'),
          onPressed: ref.read(counterProvider.notifier).increment,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class UserSection extends ConsumerWidget {
  const UserSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(currentUserProvider)) {
      AsyncData(:final User value) => Row(
        children: [
          Expanded(child: Text('User: ${value.name}')),
          TextButton(
            onPressed: () =>
                ref.read(currentUserProvider.notifier).rename('Renamed'),
            child: const Text('Rename'),
          ),
        ],
      ),
      AsyncError(:final error) => Text('User failed: $error'),
      _ => const LinearProgressIndicator(),
    };
  }
}

class TickerSection extends ConsumerWidget {
  const TickerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tick = ref.watch(tickerProvider);

    return Text('Ticker: ${tick.value ?? '-'}');
  }
}

class TodoSection extends ConsumerWidget {
  const TodoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoListProvider);
    final addTodoState = ref.watch(addTodoMutation);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Todos')),
            if (addTodoState is MutationPending)
              const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              TextButton(
                key: const Key('addTodo'),
                onPressed: () => addTodo(ref, 'A new todo'),
                child: const Text('Add'),
              ),
          ],
        ),
        if (addTodoState case MutationError(:final error))
          Text('Could not add the todo: $error'),
        switch (todos) {
          AsyncData(:final List<Todo> value) => Column(
            children: [for (final todo in value) TodoTile(id: todo.id)],
          ),
          AsyncError(:final error) => Text('Todos failed: $error'),
          _ => const LinearProgressIndicator(),
        },
      ],
    );
  }
}

/// Reads a single todo out of the [todoProvider] family.
class TodoTile extends ConsumerWidget {
  const TodoTile({required this.id, super.key});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(todoProvider(id))) {
      AsyncData(:final Todo value) => ListTile(title: Text(value.title)),
      AsyncError(:final error) => ListTile(title: Text('$error')),
      _ => const ListTile(title: LinearProgressIndicator()),
    };
  }
}
