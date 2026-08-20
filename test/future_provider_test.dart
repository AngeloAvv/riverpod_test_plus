import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';

import 'fixtures.dart';

void main() {
  group('FutureProvider', () {
    riverpodTest<AsyncValue<String>>(
      'emits loading then data',
      provider: userNameProvider,
      overrides: () => [
        userRepositoryProvider.overrideWithValue(FakeUserRepository('mocked')),
      ],
      wait: const Duration(milliseconds: 10),
      expect: () => [isLoading, isData('mocked')],
    );

    riverpodTest<AsyncValue<String>>(
      'emits loading then error, and reports the failure',
      provider: userNameProvider,
      overrides: () => [
        userRepositoryProvider.overrideWithValue(FailingUserRepository()),
      ],
      retry: noRetry,
      wait: const Duration(milliseconds: 10),
      expect: () => [isLoading, isAsyncError<Boom>()],
    );

    riverpodTest<String>(
      'select narrows the observed state',
      provider: userNameProvider.select((value) => value.value ?? ''),
      overrides: () => [
        userRepositoryProvider.overrideWithValue(FakeUserRepository('narrow')),
      ],
      wait: const Duration(milliseconds: 10),
      expect: () => ['', 'narrow'],
      verify: (ref) async {
        expect(await ref.read(userNameProvider.future), 'narrow');
      },
    );
  });
}
