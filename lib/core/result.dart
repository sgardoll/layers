/// A Result type for handling success and failure states
sealed class Result<T> {
  const Result();

  /// Creates a successful result
  static Result<T> success<T>(T data) => Success<T>(data);

  /// Creates a failure result
  static Result<T> failure<T>(String message, [Object? error]) => Failure<T>(message, error);
}

/// Represents a successful result containing data
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> && runtimeType == other.runtimeType && data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success(data: $data)';
}

/// Represents a failure result containing an error message
class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, [this.error]);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          error == other.error;

  @override
  int get hashCode => Object.hash(message, error);

  @override
  String toString() => 'Failure(message: $message, error: $error)';
}

extension ResultExtension<T> on Result<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failure() => null,
  };

  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Object? error) failure,
  }) {
    return switch (this) {
      Success(:final data) => success(data),
      Failure(:final message, :final error) => failure(message, error),
    };
  }
}
