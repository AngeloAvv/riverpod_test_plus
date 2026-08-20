import 'package:riverpod/riverpod.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('matchers', () {
    test('isLoading matches a loading state', () {
      expect(AsyncLoading<int>(), isLoading);
      expect(AsyncData(1), isNot(isLoading));
    });

    test('isData matches the held value', () {
      expect(AsyncData(1), isData(1));
      expect(AsyncData(1), isData(isPositive));
      expect(AsyncData(1), isNot(isData(2)));
      expect(AsyncLoading<int>(), isNot(isData(1)));
    });

    test('isAsyncError matches the error type', () {
      final error = AsyncError<int>(const Boom(), StackTrace.empty);
      expect(error, isAsyncError<Boom>());
      expect(error, isAsyncError<Boom>(const Boom()));
      expect(error, isNot(isAsyncError<StateError>()));
      expect(AsyncData(1), isNot(isAsyncError<Boom>()));
    });
  });
}
