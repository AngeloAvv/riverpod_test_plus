import 'package:riverpod/experimental/mutation.dart';
import 'package:riverpod_test_plus/riverpod_test_plus.dart';
import 'package:test/test.dart';

import 'fixtures.dart';

void main() {
  group('Mutation', () {
    riverpodTest<MutationState<String>>(
      'goes from idle to pending to success',
      provider: renameCounter,
      act: (ref) async {
        await renameCounter.run(
          ref,
          (tsx) => tsx.get(nameProvider.notifier).rename('renamed'),
        );
      },
      expect: () => [isIdle, isPending, isSuccess('renamed')],
      verify: (ref) {
        expect(ref.read(nameProvider), 'renamed');
      },
    );

    riverpodTest<MutationState<String>>(
      'reports a failing mutation',
      provider: renameCounter,
      // Mutation.run sets MutationError and then rethrows; act swallowing that
      // rethrow is what lets the assertion live in expect.
      act: (ref) => renameCounter.run(
        ref,
        (tsx) => tsx.get(nameProvider.notifier).failToRename(),
      ),
      expect: () => [isIdle, isPending, isMutationError<Boom>()],
    );
  });
}
