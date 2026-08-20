import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:riverpod_test_plus_example/counter/counter_provider.dart';

void main() {
  group('counterProvider', () {
    riverpodTest<int>(
      'starts at 0',
      provider: counterProvider,
      expect: () => [0],
    );

    riverpodTest<int>(
      'increments',
      provider: counterProvider,
      act: (ref) => ref.notifier(counterProvider).increment(),
      expect: () => [0, 1],
    );

    riverpodTest<int>(
      'decrements twice',
      provider: counterProvider,
      act: (ref) {
        ref.notifier(counterProvider)
          ..decrement()
          ..decrement();
      },
      expect: () => [0, -1, -2],
    );

    riverpodTest<int>(
      'skips the initial state',
      provider: counterProvider,
      act: (ref) => ref.notifier(counterProvider).increment(),
      skip: 1,
      expect: () => [1],
    );

    riverpodTest<int>(
      'does not record the state it builds to',
      provider: counterProvider,
      fireImmediately: false,
      act: (ref) => ref.notifier(counterProvider).increment(),
      expect: () => [1],
    );
  });
}
