# Changelog

## 0.1.0

Initial release.

- A single `riverpodTest` function covering every Riverpod 3 provider type:
  `Provider`, `FutureProvider`, `StreamProvider`, `Notifier`, `AsyncNotifier`,
  `StreamNotifier`, their `family` variants and mutations — one signature, no
  per-provider helpers.
- `TestRef`, a thin wrapper over the test container, with `ref.notifier(...)`
  to drive notifiers from `act` and `ref.read`/`ref.listen` for everything else.
- No dedicated seeding parameter: a test starts a provider from the state it
  needs through `overrides`, with Riverpod's own `overrideWithBuild` and
  `overrideWith`.
- Matchers for `AsyncValue` (`isData`, `isLoading`, `isAsyncError`) and for
  mutation states (`isIdle`, `isPending`, `isSuccess`, `isMutationError`), so
  expectations read like the API under test.
- Errors are part of the emitted sequence: an async failure is an `AsyncError`
  state, and a provider with no state to fail into puts the error object itself
  in the list `expect` asserts on. No separate `errors` channel.
- Readable failure output: emitted states are diffed against the expectation
  instead of being dumped side by side.
