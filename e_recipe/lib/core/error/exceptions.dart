class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class CacheException extends AppException {
  CacheException(super.message);
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(super.message);
}
