import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:riverpod_test_plus_example/greeting/greeting_provider.dart';

void main() {
  group('greetingProvider', () {
    riverpodTest<String>(
      'builds to its greeting',
      provider: greetingProvider,
      expect: () => ['Hello, Riverpod!'],
    );

    riverpodTest<String>(
      'can be overridden',
      provider: greetingProvider,
      overrides: () => [greetingProvider.overrideWithValue('Ciao!')],
      expect: () => ['Ciao!'],
    );

    riverpodTest<int>(
      'works on a .select derivation too',
      provider: greetingProvider.select((greeting) => greeting.length),
      expect: () => [16],
    );

    riverpodTest<String>(
      'exposes the container through verify',
      provider: greetingProvider,
      verify: (ref) {
        expect(ref.exists(greetingProvider), isTrue);
        expect(ref.read(greetingProvider), 'Hello, Riverpod!');
      },
    );
  });
}
