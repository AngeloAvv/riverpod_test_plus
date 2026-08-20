import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:riverpod_test_plus_example/ticker/ticker_provider.dart';

void main() {
  group('tickerProvider', () {
    riverpodTest<AsyncValue<int>>(
      'emits three ticks',
      provider: tickerProvider,
      // The ticker is driven by a real timer: give it time to run.
      wait: const Duration(milliseconds: 120),
      expect: () => [isLoading, isData(0), isData(1), isData(2)],
    );

    riverpodTest<AsyncValue<int>>(
      'can be replaced by a synchronous stream',
      provider: tickerProvider,
      overrides: () => [
        tickerProvider.overrideWith((ref) => Stream.fromIterable([7, 8])),
      ],
      expect: () => [isLoading, isData(7), isData(8)],
    );

    riverpodTest<AsyncValue<int>>(
      'reports the stream error',
      provider: tickerProvider,
      overrides: () => [
        tickerProvider.overrideWith(
          (ref) => Stream<int>.error(StateError('boom')),
        ),
      ],
      retry: noRetry,
      expect: () => [isLoading, isAsyncError<StateError>()],
    );
  });
}
