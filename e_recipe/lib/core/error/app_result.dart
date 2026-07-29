import 'package:e_recipe/core/error/failures.dart';

sealed class AppResult<T> {
  const AppResult();

  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  );
}

final class ResultSuccess<T> extends AppResult<T> {
  final T value;

  const ResultSuccess(this.value);

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    return onSuccess(value);
  }
}

final class ResultFailure<T> extends AppResult<T> {
  final Failure failure;

  const ResultFailure(this.failure);

  @override
  R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    return onFailure(failure);
  }
}
