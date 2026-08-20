import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('families', () {
    riverpodTest<int>(
      'a functional family is just a provider',
      provider: tripleProvider(3),
      expect: () => [9],
    );

    riverpodTest<String>(
      'a notifier family exposes its notifier',
      provider: labelProvider(2),
      act: (ref) => ref.notifier(labelProvider(2)).shout(),
      expect: () => ['label-2', 'LABEL-2'],
    );

    riverpodTest<String>(
      'sibling arguments hold independent states',
      provider: labelProvider(1),
      act: (ref) => ref.notifier(labelProvider(2)).shout(),
      expect: () => ['label-1'],
      verify: (ref) {
        expect(ref.read(labelProvider(2)), 'LABEL-2');
      },
    );
  });
}
