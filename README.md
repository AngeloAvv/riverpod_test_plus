# riverpod_test_plus

[![pub](https://img.shields.io/pub/v/riverpod_test_plus.svg)](https://pub.dev/packages/riverpod_test_plus)

Test any Riverpod 3 provider with a single function. `riverpodTest` observes the target in a
disposable container, acts on it, and asserts on the sequence it emits — with a colored diff when
the expectation does not match.

There is exactly **one** function, not one per provider kind. In Riverpod 3 everything observable
implements `ProviderListenable<StateT>` — `Provider`, `FutureProvider`, `StreamProvider`,
`NotifierProvider`, `AsyncNotifierProvider`, `StreamNotifierProvider`, an applied family, a
`.select` derivation, a `.future` and even a `Mutation` — so one function covers every target,
rather than one helper per provider type.

## Documentation

Full documentation at **[docs.page/AngeloAvv/riverpod_test_plus](https://docs.page/AngeloAvv/riverpod_test_plus)**.

## Installation

```yaml
# pubspec.yaml
dev_dependencies:
  riverpod_test_plus: ^0.1.0
```

It depends on `package:riverpod` and `package:test` only, so it works in pure Dart packages as well
as in Flutter ones. Widget tests stay Flutter's: `testWidgets` with a `ProviderScope` around the
widget under test.

## Usage

### Notifier providers

```dart
final counterProvider = NotifierProvider<Counter, int>(Counter.new);

class Counter extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

riverpodTest(
  'emits [0, 1, 2] when increment is called twice',
  provider: counterProvider,
  act: (ref) {
    ref.notifier(counterProvider)
      ..increment()
      ..increment();
  },
  expect: () => [0, 1, 2],
);
```

`act` and `verify` receive a `TestRef`: `container`, `read`, `listen`, `refresh`, `invalidate`,
`exists`, plus the `notifier(provider)` shorthand. It exists because no single object fits every
target — a `Provider` has no notifier, a family is a factory, and a mutation is triggered from
somewhere else entirely.

### Async providers

The observed states of an async provider are `AsyncValue`s, and `expect` receives the real
sequence. Matchers are exported for them:

```dart
riverpodTest(
  'emits [loading, data] while loading the user',
  provider: userProvider,
  setUp: () {
    repository = MockUserRepository();
    when(repository.fetchUser).thenAnswer((_) async => const User('Ada'));
  },
  // A callback, not a list: it runs after setUp, so `repository` exists.
  overrides: () => [userRepositoryProvider.overrideWithValue(repository)],
  expect: () => [isLoading, isData(const User('Ada'))],
);

riverpodTest(
  'emits [loading, error] when the repository fails',
  provider: userProvider,
  setUp: () {
    repository = MockUserRepository();
    when(repository.fetchUser).thenThrow(Exception('offline'));
  },
  overrides: () => [userRepositoryProvider.overrideWithValue(repository)],
  // Riverpod retries failing providers by default, which emits extra states.
  retry: noRetry,
  expect: () => [isLoading, isAsyncError<Exception>()],
);
```

### Families

A family is a provider factory, so apply it — what comes back is a provider like any other:

```dart
riverpodTest(
  'completes todo 42',
  provider: todoProvider(42),
  act: (ref) async {
    final todo = todoProvider(42);
    await ref.read(todo.future); // let the initial build settle
    await ref.notifier(todo).complete();
  },
  expect: () => [
    isLoading,
    isData(const Todo(42, done: false)),
    isData(const Todo(42, done: true)),
  ],
);
```

### Mutations

A `Mutation<T>` is a `ProviderListenable<MutationState<T>>`, so it goes straight into `provider`.
`Mutation.run` takes a `MutationTarget`, and `TestRef` is one — pass `ref` straight through:

```dart
final addTodo = Mutation<Todo>();

riverpodTest(
  'emits [idle, pending, success]',
  provider: addTodo,
  act: (ref) => addTodo.run(ref, (tsx) async {
    return tsx.get(todosProvider.notifier).add('Eat a cookie');
  }),
  expect: () => [isIdle, isPending, isSuccess(const Todo(1, 'Eat a cookie'))],
);
```

### Starting from a given state

There is no `seed` parameter: starting a provider from a state of your choosing is an override, and
Riverpod already has the methods for it — the same ones you would write in a `ProviderScope`.

```dart
// A notifier: the build is replaced, the notifier and its methods are the real ones.
riverpodTest(
  'emits [9, 10] when incrementing from 9',
  provider: counterProvider,
  overrides: () => [counterProvider.overrideWithBuild((ref, self) => 9)],
  act: (ref) => ref.notifier(counterProvider).increment(),
  expect: () => [9, 10],
);

// An async notifier: returning the value synchronously means no loading state.
riverpodTest(
  'renames a user that is already loaded',
  provider: userProvider,
  overrides: () => [
    userProvider.overrideWithBuild((ref, self) => const User('Ada')),
  ],
  act: (ref) => ref.notifier(userProvider).rename('Grace'),
  expect: () => [isData(const User('Ada')), isLoading, isData(const User('Grace'))],
);

// A functional provider has no state to set — overriding it is the whole point.
riverpodTest(
  'greets the mocked value',
  provider: greetingProvider,
  overrides: () => [greetingProvider.overrideWith((ref) => 'mocked')],
  expect: () => ['mocked'],
);
```

`overrideWithBuild` keeps the notifier and replaces only its `build`, so the value survives a
rebuild — and the original `build` never runs, dependencies included. See
[Seeding](https://docs.page/AngeloAvv/riverpod_test_plus/seeding) for the recipe per provider type,
including loading and error states.

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `description` | `String` | required, positional | Test description, forwarded to `test`. |
| `provider` | `ProviderListenable<StateT>` | required | The target to observe: any provider, applied family, `.future`, `.select(...)` or `Mutation`. |
| `setUp` | `FutureOr<void> Function()?` | `null` | Runs first, before the container exists. Build and stub mocks here. |
| `overrides` | `List<Override> Function()?` | `null` | Container overrides: mocked dependencies, and the state the provider under test starts from. A callback, so it can reference objects created in `setUp`. |
| `observers` | `List<ProviderObserver>?` | `null` | Observers installed on the test container. |
| `retry` | `Retry?` | Riverpod's default policy | Container retry policy. Pass `noRetry` when asserting on errors. |
| `act` | `FutureOr<void> Function(TestRef ref)?` | `null` | Interacts with the provider. Awaited. An exception thrown here does not fail the test. |
| `wait` | `Duration?` | `null` | Awaited after `act`. There is no automatic settling. |
| `fireImmediately` | `bool` | `true` | Whether the state the provider builds to is the first recorded element. |
| `skip` | `int` | `0` | Drops the first N emissions before comparing. |
| `expect` | `dynamic Function()?` | `null` | What the provider is expected to emit — states and errors alike: values, matchers, or one matcher for the whole sequence. |
| `verify` | `dynamic Function(TestRef ref)?` | `null` | Runs after `expect`, container still alive. |
| `tearDown` | `FutureOr<void> Function()?` | `null` | Runs last; the container is disposed afterwards. |
| `tags` | `dynamic` | `null` | Forwarded to `test`. |

Exported alongside `riverpodTest`: `TestRef`, `Retry`, `noRetry`, `NotifierProviderOf`, and the
matchers `isLoading`, `isData`, `isAsyncError`, `isIdle`, `isPending`, `isSuccess`,
`isMutationError`.

## Design decisions

**One signature.** Everything observable in Riverpod 3 is a `ProviderListenable<StateT>`, mutations
included, so a per-provider taxonomy of test helpers would describe a distinction the framework
itself does not make. One function covers every target.

**No `seed` parameter.** Starting a provider from a given state is an override, and Riverpod already
names the operation: `overrideWithBuild` for a notifier provider, `overrideWith` for a functional
one. A dedicated parameter would be a second vocabulary for the same thing, and one that covered
only half the provider types — only a notifier owns a state to set. Everything goes through
`overrides`, and what you write there works unchanged in a `ProviderScope`.

**Errors belong to the sequence, not to a separate parameter.** There is no `errors` argument. An
async provider already reports a failure as an `AsyncError` state and a mutation as `MutationError`;
a synchronous provider has no state to fail into, so the error object itself takes its place in the
list `expect` asserts on — matched by type with `isA<E>()` or by value. A failure always has a
place in the sequence, so a second channel would only duplicate it.
As a consequence an exception thrown by `act` does not fail the test: `Mutation.run` records
`MutationError` and *then* rethrows, and that rethrow must not destroy the assertion it enables. It
is printed via `printOnFailure`, so it shows up only when the test fails anyway.

**Lazy `overrides`.** A `List<Override>` would be evaluated while `test` collects test cases, before
any `setUp` body has run, so an override referencing a mock created in `setUp` would explode. The
callback shape is what makes `setUp` and `overrides` compose.

**No automatic settling.** The runner awaits a single microtask turn after `act`. Anything with
real timing is opted into explicitly with `wait`, keeping the test's timing visible in the test.

**An internal container.** Every test runs in its own `ProviderContainer.test()`, disposed
automatically; `ref.container` is the escape hatch for whatever `TestRef` does not wrap.

## Example

The [`example/`](example) directory is a small Flutter app — a counter, an async user fetch behind a
repository, a ticker stream, a todo family and a mutation — paired with a test file per provider
kind. Run it with:

```sh
cd example
flutter test
```

## Contributing

1. Fork the repository and create a feature branch.
2. Keep `dart analyze` clean and `dart format` idempotent.
3. Add or update tests for any changed behaviour. Run `dart test`.
4. Open a pull request describing what changed and why.

Bug reports and feature requests: [issue tracker](https://github.com/AngeloAvv/riverpod_test_plus/issues).

## License

MIT — see [LICENSE](LICENSE).
