import 'package:riverpod/experimental/mutation.dart';
import 'package:riverpod/misc.dart';
import 'package:riverpod/riverpod.dart';

import 'internal_bridge.dart';

/// The handle passed to `act` and `verify`.
///
/// No single object fits every target: a plain `Provider` has no notifier, a
/// family is a provider factory and a mutation is triggered from somewhere else
/// entirely. [TestRef] is that missing handle — it wraps the container the test
/// runs in.
final class TestRef implements MutationTarget {
  /// Creates a [TestRef] around [container].
  const TestRef(this.container);

  /// The container the test runs in.
  ///
  /// Escape hatch for anything this class does not expose.
  ///
  /// Implementing [MutationTarget] through it also means a mutation can be run
  /// straight from `act`: `addTodo.run(ref, (tsx) async { ... })`.
  @override
  final ProviderContainer container;

  /// Reads the current value of [listenable].
  StateT read<StateT>(ProviderListenable<StateT> listenable) {
    return container.read(listenable);
  }

  /// Listens to [listenable] for the remainder of the test.
  ProviderSubscription<StateT> listen<StateT>(
    ProviderListenable<StateT> listenable,
    void Function(StateT? previous, StateT next) listener, {
    bool fireImmediately = false,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return container.listen<StateT>(
      listenable,
      listener,
      fireImmediately: fireImmediately,
      onError: onError,
    );
  }

  /// Refreshes [refreshable] and returns its new value.
  StateT refresh<StateT>(Refreshable<StateT> refreshable) {
    return container.refresh(refreshable);
  }

  /// Invalidates [provider], scheduling a rebuild.
  void invalidate(ProviderOrFamily provider, {bool asReload = false}) {
    container.invalidate(provider, asReload: asReload);
  }

  /// Whether [provider] has been initialized in this container.
  bool exists(ProviderBase<Object?> provider) => container.exists(provider);

  /// Reads the notifier of [provider].
  ///
  /// Shorthand for `read(provider.notifier)`, accepting every notifier provider
  /// — including families and code-generated ones.
  NotifierT notifier<NotifierT extends AnyNotifier<Object?, Object?>>(
    NotifierProviderOf<NotifierT> provider,
  ) {
    return readNotifier(container, provider);
  }
}
