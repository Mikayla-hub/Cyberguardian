class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ServerException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ServerException(message: $message, statusCode: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  const CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'No internet connection'});
}

class AuthException implements Exception {
  final String message;
  final int? statusCode;
  const AuthException({required this.message, this.statusCode});
}

class SecurityException implements Exception {
  final String message;
  const SecurityException({required this.message});
}
