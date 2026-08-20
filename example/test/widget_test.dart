import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test_plus_example/main.dart';
import 'package:riverpod_test_plus_example/todo/todo.dart';
import 'package:riverpod_test_plus_example/todo/todo_repository.dart';
import 'package:riverpod_test_plus_example/user/user_repository.dart';

import 'fakes.dart';

/// riverpod_test_plus covers the unit-test side; widget tests stay plain
/// `testWidgets` with a `ProviderScope`.
void main() {
  testWidgets('increments the counter from the UI', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          todoRepositoryProvider.overrideWithValue(FakeTodoRepository()),
        ],
        child: const ExampleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('count')), findsOneWidget);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byKey(const Key('increment')));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('adds a todo through the mutation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userRepositoryProvider.overrideWithValue(FakeUserRepository()),
          todoRepositoryProvider.overrideWithValue(
            FakeTodoRepository(
              todos: const [Todo(id: 1, title: 'Write a provider')],
            ),
          ),
        ],
        child: const ExampleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Write a provider'), findsOneWidget);

    await tester.tap(find.byKey(const Key('addTodo')));
    await tester.pumpAndSettle();

    expect(find.text('A new todo'), findsOneWidget);
  });
}
