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
    super.message = 'Network error occurred',
  }) : super(
          statusCode: 0,
          type: ApiExceptionType.network,
        );
}

class TimeoutException extends ApiException {
  const TimeoutException({
    super.message = 'Request timeout',
  }) : super(
          statusCode: 408,
          type: ApiExceptionType.timeout,
        );
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Server error occurred',
    super.statusCode = 500,
  }) : super(
          type: ApiExceptionType.server,
        );
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({
    super.message = 'Authentication required',
  }) : super(
          statusCode: 401,
          type: ApiExceptionType.unauthorized,
        );
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = 'Access forbidden',
  }) : super(
          statusCode: 403,
          type: ApiExceptionType.forbidden,
        );
}

class NotFoundException extends ApiException {
  const NotFoundException({
    super.message = 'Resource not found',
  }) : super(
          statusCode: 404,
          type: ApiExceptionType.notFound,
        );
}

class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Validation failed',
    super.details,
  }) : super(
          statusCode: 422,
          type: ApiExceptionType.validation,
        );
}

class ConflictException extends ApiException {
  const ConflictException({
    super.message = 'Resource conflict',
  }) : super(
          statusCode: 409,
          type: ApiExceptionType.conflict,
        );
}