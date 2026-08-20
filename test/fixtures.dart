import 'dart:async';

import 'package:riverpod/experimental/mutation.dart';
import 'package:riverpod/riverpod.dart';

/// Thrown by the fixtures that exercise the error paths.
final class Boom implements Exception {
  const Boom();

  @override
  String toString() => 'Boom';
}

// --- Functional providers ---------------------------------------------------

final greetingProvider = Provider<String>((ref) => 'hello');

class UserRepository {
  Future<String> fetchName() async => 'live';
}

class FakeUserRepository implements UserRepository {
  FakeUserRepository(this.name);

  final String name;

  @override
  Future<String> fetchName() async => name;
}

class FailingUserRepository implements UserRepository {
  @override
  Future<String> fetchName() async => throw const Boom();
}

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(),
);

final userNameProvider = FutureProvider<String>(
  (ref) => ref.watch(userRepositoryProvider).fetchName(),
);

final tickerProvider = StreamProvider<int>(
  (ref) => Stream.fromIterable([1, 2, 3]),
);

// --- Failing providers ------------------------------------------------------

/// A synchronous provider whose failure has no state to live in: it surfaces as
/// an error in the emitted sequence.
final boomProvider = Provider<int>((ref) => throw const Boom());

final thresholdProvider = NotifierProvider<ThresholdNotifier, int>(
  ThresholdNotifier.new,
);

class ThresholdNotifier extends Notifier<int> {
  @override
  int build() => 1;

  void update(int value) => state = value;
}

/// Fails for one value of [thresholdProvider] and recovers afterwards, so its
/// sequence interleaves states and errors.
final flakyProvider = Provider<int>((ref) {
  final threshold = ref.watch(thresholdProvider);
  if (threshold == 2) throw const Boom();
  return threshold * 10;
});

// --- Notifier providers -----------------------------------------------------

final counterProvider = NotifierProvider<CounterNotifier, int>(
  CounterNotifier.new,
);

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;

  void explode() => throw const Boom();
}

final asyncCounterProvider = AsyncNotifierProvider<AsyncCounterNotifier, int>(
  AsyncCounterNotifier.new,
);

class AsyncCounterNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() async => 0;

  Future<void> increment() async {
    state = AsyncData(state.requireValue + 1);
  }

  Future<void> fail() async {
    state = await AsyncValue.guard<int>(() async => throw const Boom());
  }
}

final streamCounterProvider =
    StreamNotifierProvider<StreamCounterNotifier, int>(
      StreamCounterNotifier.new,
    );

class StreamCounterNotifier extends StreamNotifier<int> {
  final _controller = StreamController<int>();

  @override
  Stream<int> build() {
    ref.onDispose(_controller.close);
    return _controller.stream;
  }

  void emit(int value) => _controller.add(value);
}

/// A notifier whose `build` depends on another provider, used to show that an
/// overridden build survives a rebuild.
final scaledCounterProvider = NotifierProvider<ScaledCounterNotifier, int>(
  ScaledCounterNotifier.new,
);

class ScaledCounterNotifier extends Notifier<int> {
  @override
  int build() => ref.watch(thresholdProvider) * 10;

  void increment() => state++;
}

// --- Families ---------------------------------------------------------------

final tripleProvider = Provider.family<int, int>((ref, value) => value * 3);

final labelProvider = NotifierProvider.family<LabelNotifier, String, int>(
  LabelNotifier.new,
);

class LabelNotifier extends Notifier<String> {
  LabelNotifier(this.id);

  final int id;

  @override
  String build() => 'label-$id';

  void shout() => state = state.toUpperCase();
}

// --- Mutations --------------------------------------------------------------

final renameCounter = Mutation<String>();

final nameProvider = NotifierProvider<NameNotifier, String>(NameNotifier.new);

class NameNotifier extends Notifier<String> {
  @override
  String build() => 'initial';

  Future<String> rename(String name) async {
    state = name;
    return name;
  }

  Future<String> failToRename() async => throw const Boom();
}
