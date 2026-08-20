import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('Provider', () {
    riverpodTest<String>(
      'emits the built value',
      provider: greetingProvider,
      expect: () => ['hello'],
    );

    riverpodTest<String>(
      'emits nothing when fireImmediately is false',
      provider: greetingProvider,
      fireImmediately: false,
      expect: () => <String>[],
    );

    riverpodTest<String>(
      'reads the overridden value',
      provider: greetingProvider,
      overrides: () => [greetingProvider.overrideWithValue('mocked')],
      expect: () => ['mocked'],
      verify: (ref) {
        expect(ref.read(greetingProvider), 'mocked');
      },
    );

    riverpodTest<int>(
      'emits again after an invalidation',
      provider: counterProvider,
      act: (ref) {
        ref.notifier(counterProvider).increment();
        ref.invalidate(counterProvider);
      },
      expect: () => [0, 1, 0],
    );
  });
}
