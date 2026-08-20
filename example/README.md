# riverpod_test_plus example

A small Flutter app showing every kind of Riverpod 3 target that
[`riverpod_test_plus`](../) can test, plus the tests that cover them.

## The app

`lib/` is split by feature, all providers are hand written (no `build_runner`):

| File | Target |
| --- | --- |
| `lib/greeting/greeting_provider.dart` | `Provider` |
| `lib/counter/counter_provider.dart` | `NotifierProvider` |
| `lib/user/user_providers.dart` | `FutureProvider` and `AsyncNotifierProvider`, both fed by an injected `UserRepository` |
| `lib/ticker/ticker_provider.dart` | `StreamProvider` |
| `lib/todo/todo_providers.dart` | a `FutureProvider.family`, an `AsyncNotifierProvider` and a `Mutation` |

`lib/main.dart` wires them into a `MaterialApp` under a `ProviderScope`.

## The tests

`test/` has one file per target, each one a showcase of `riverpodTest`:

- `provider_test.dart` — plain provider, `overrides`, `.select`, `verify`
- `notifier_test.dart` — `act`, `skip`, `fireImmediately`
- `async_notifier_test.dart` — `AsyncValue` sequences, `.future`, `retry: noRetry`, error states
- `stream_provider_test.dart` — `wait`, overriding a stream
- `family_test.dart` — passing `todoProvider(id)`
- `mutation_test.dart` — `isIdle` / `isPending` / `isSuccess` / `isMutationError`
- `seeding_test.dart` — starting from a given state with `overrideWithBuild`
- `widget_test.dart` — a plain `testWidgets`, to show that widget tests stay
  Flutter's own while `riverpodTest` covers the unit tests

Fakes are hand written in `test/fakes.dart` — no mocking package.

## Running

```sh
fvm flutter pub get
fvm flutter analyze
fvm flutter test
```
