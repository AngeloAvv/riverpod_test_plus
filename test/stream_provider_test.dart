import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';

import 'fixtures.dart';

void main() {
  group('StreamProvider', () {
    riverpodTest<AsyncValue<int>>(
      'emits every event of the stream',
      provider: tickerProvider,
      wait: const Duration(milliseconds: 10),
      expect: () => [isLoading, isData(1), isData(2), isData(3)],
    );

    riverpodTest<AsyncValue<int>>(
      'skips the loading state',
      provider: tickerProvider,
      skip: 1,
      wait: const Duration(milliseconds: 10),
      expect: () => [isData(1), isData(2), isData(3)],
    );
  });
}
