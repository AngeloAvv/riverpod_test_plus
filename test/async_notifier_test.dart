import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('AsyncNotifierProvider', () {
    riverpodTest<AsyncValue<int>>(
      'emits loading then the built state',
      provider: asyncCounterProvider,
      wait: const Duration(milliseconds: 10),
      expect: () => [isLoading, isData(0)],
    );

    riverpodTest<AsyncValue<int>>(
      'emits the incremented state',
      provider: asyncCounterProvider,
      act: (ref) async {
        await ref.read(asyncCounterProvider.future);
        await ref.notifier(asyncCounterProvider).increment();
      },
      expect: () => [isLoading, isData(0), isData(1)],
    );

    riverpodTest<AsyncValue<int>>(
      'emits an error state without failing the test',
      provider: asyncCounterProvider,
      act: (ref) async {
        await ref.read(asyncCounterProvider.future);
        await ref.notifier(asyncCounterProvider).fail();
      },
      expect: () => [isLoading, isData(0), isAsyncError<Boom>()],
    );
  });
}
