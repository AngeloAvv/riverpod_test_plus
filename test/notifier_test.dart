import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('NotifierProvider', () {
    riverpodTest<int>(
      'emits the built state',
      provider: counterProvider,
      expect: () => [0],
    );

    riverpodTest<int>(
      'emits the incremented state',
      provider: counterProvider,
      act: (ref) => ref.notifier(counterProvider).increment(),
      expect: () => [0, 1],
    );

    riverpodTest<int>(
      'skips the states asked for',
      provider: counterProvider,
      act: (ref) {
        final notifier = ref.notifier(counterProvider);
        notifier
          ..increment()
          ..increment();
      },
      skip: 2,
      expect: () => [2],
    );

    riverpodTest<int>(
      'verify runs against a live container',
      provider: counterProvider,
      act: (ref) => ref.notifier(counterProvider).increment(),
      expect: () => [0, 1],
      verify: (ref) {
        expect(ref.read(counterProvider), 1);
        expect(ref.exists(counterProvider), isTrue);
      },
    );
  });
}
