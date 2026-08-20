import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('StreamNotifierProvider', () {
    riverpodTest<AsyncValue<int>>(
      'emits every value pushed on the stream',
      provider: streamCounterProvider,
      act: (ref) async {
        ref.notifier(streamCounterProvider)
          ..emit(1)
          ..emit(2);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [isLoading, isData(1), isData(2)],
    );
  });
}
