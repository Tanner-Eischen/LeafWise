enum ApiExceptionType {
  network,
  timeout,
  server,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  tooManyRequests,
  cancel,
  unknown,
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final ApiExceptionType type;
  final Map<String, dynamic>? details;

  const ApiException({
    required this.message,
    required this.statusCode,
    required this.type,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode, Type: $type)';
  }

  bool get isNetworkError => type == ApiExceptionType.network;
  bool get isTimeoutError => type == ApiExceptionType.timeout;
  bool get isServerError => type == ApiExceptionType.server;
  bool get isClientError => [
        ApiExceptionType.badRequest,
        ApiExceptionType.unauthorized,
        ApiExceptionType.forbidden,
        ApiExceptionType.notFound,
        ApiExceptionType.conflict,
        ApiExceptionType.validation,
        ApiExceptionType.tooManyRequests,
      ].contains(type);
  bool get isAuthError => [
        ApiExceptionType.unauthorized,
        ApiExceptionType.forbidden,
      ].contains(type);
  bool get isValidationError => type == ApiExceptionType.validation;
}

class NetworkException extends ApiException {
  const NetworkException({
    String message = 'Network error occurred',
  }) : super(
          message: message,
          statusCode: 0,
          type: ApiExceptionType.network,
        );
}

class TimeoutException extends ApiException {
  const TimeoutException({
    String message = 'Request timeout',
  }) : super(
          message: message,
          statusCode: 408,
          type: ApiExceptionType.timeout,
        );
}

class ServerException extends ApiException {
  const ServerException({
    String message = 'Server error occurred',
    int statusCode = 500,
  }) : super(
          message: message,
          statusCode: statusCode,
          type: ApiExceptionType.server,
        );
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    String message = 'Authentication required',
  }) : super(
          message: message,
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    String message = 'Access forbidden',
  }) : super(
          message: message,
          statusCode: 403,
          type: ApiExceptionType.forbidden,
        );
}

class NotFoundException extends ApiException {
  const NotFoundException({
    String message = 'Resource not found',
  }) : super(
          message: message,
          statusCode: 404,
          type: ApiExceptionType.notFound,
        );
}

class ValidationException extends ApiException {
  const ValidationException({
    String message = 'Validation failed',
    Map<String, dynamic>? details,
  }) : super(
          message: message,
          statusCode: 422,
          type: ApiExceptionType.validation,
          details: details,
        );
}

class ConflictException extends ApiException {
  const ConflictException({
    String message = 'Resource conflict',
  }) : super(
          message: message,
          statusCode: 409,
          type: ApiExceptionType.conflict,
        );
}