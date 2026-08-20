import 'package:riverpod/experimental/mutation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

/// Matches an [AsyncValue] that is currently loading.
///
/// Also matches a reload, i.e. an [AsyncData] or [AsyncError] carrying a
/// pending refresh.
final Matcher isLoading = isA<AsyncValue<Object?>>().having(
  (value) => value.isLoading,
  'isLoading',
  isTrue,
);

/// Matches an [AsyncData] holding [value].
///
/// [value] may itself be a [Matcher].
Matcher isData(Object? value) =>
    isA<AsyncData<Object?>>().having((data) => data.value, 'value', value);

/// Matches an [AsyncError] whose error is of type [ErrorT].
///
/// Pass [error] to also assert on the error itself.
Matcher isAsyncError<ErrorT extends Object>([Object? error]) {
  var matcher = isA<AsyncError<Object?>>().having(
    (asyncError) => asyncError.error,
    'error',
    isA<ErrorT>(),
  );
  if (error != null) {
    matcher = matcher.having((asyncError) => asyncError.error, 'error', error);
  }
  return matcher;
}

/// Matches a mutation that has not started, or that was reset.
final Matcher isIdle = isA<MutationIdle<Object?>>();

/// Matches a mutation that is currently running.
final Matcher isPending = isA<MutationPending<Object?>>();

/// Matches a mutation that completed with [value].
///
/// [value] may itself be a [Matcher].
Matcher isSuccess(Object? value) => isA<MutationSuccess<Object?>>().having(
  (success) => success.value,
  'value',
  value,
);

/// Matches a mutation that failed with an error of type [ErrorT].
///
/// Pass [error] to also assert on the error itself.
Matcher isMutationError<ErrorT extends Object>([Object? error]) {
  var matcher = isA<MutationError<Object?>>().having(
    (mutationError) => mutationError.error,
    'error',
    isA<ErrorT>(),
  );
  if (error != null) {
    matcher = matcher.having(
      (mutationError) => mutationError.error,
      'error',
      error,
    );
  }
  return matcher;
}
