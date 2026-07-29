abstract class Failure {
  final String message;

  const Failure(this.message);
}

class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    String message = "Local database operation failure",
  }) : super(message);
}

class ApiFailure extends Failure {
  final int? statusCode;

  const ApiFailure({this.statusCode, required String message}) : super(message);
}
