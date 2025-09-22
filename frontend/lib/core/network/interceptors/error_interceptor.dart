import 'package:dio/dio.dart';
import 'package:leafwise/core/exceptions/api_exception.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _handleError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: apiException,
        type: err.type,
        response: err.response,
      ),
    );
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 408,
          type: ApiExceptionType.timeout,
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          statusCode: 0,
          type: ApiExceptionType.cancel,
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message:
              'No internet connection. Please check your network settings.',
          statusCode: 0,
          type: ApiExceptionType.network,
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Certificate verification failed.',
          statusCode: 0,
          type: ApiExceptionType.network,
        );

      case DioExceptionType.unknown:
      default:
        return const ApiException(
          message: 'An unexpected error occurred. Please try again.',
          statusCode: 0,
          type: ApiExceptionType.unknown,
        );
    }
  }

  ApiException _handleResponseError(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode ?? 0;
    final data = response?.data;

    String message = 'An error occurred. Please try again.';
    ApiExceptionType type = ApiExceptionType.server;

    // Try to extract error message from response
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        message = data['detail'].toString();
      } else if (data.containsKey('message')) {
        message = data['message'].toString();
      } else if (data.containsKey('error')) {
        message = data['error'].toString();
      }
    } else if (data is String) {
      message = data;
    }

    // Handle specific status codes
    switch (statusCode) {
      case 400:
        type = ApiExceptionType.badRequest;
        if (message.isEmpty) {
          message = 'Invalid request. Please check your input.';
        }
        break;
      case 401:
        type = ApiExceptionType.unauthorized;
        message = 'Authentication failed. Please log in again.';
        break;
      case 403:
        type = ApiExceptionType.forbidden;
        message =
            'Access denied. You don\'t have permission to perform this action.';
        break;
      case 404:
        type = ApiExceptionType.notFound;
        message = 'The requested resource was not found.';
        break;
      case 409:
        type = ApiExceptionType.conflict;
        if (message.isEmpty) {
          message = 'A conflict occurred. The resource may already exist.';
        }
        break;
      case 422:
        type = ApiExceptionType.validation;
        if (message.isEmpty) {
          message = 'Validation failed. Please check your input.';
        }
        break;
      case 429:
        type = ApiExceptionType.tooManyRequests;
        message = 'Too many requests. Please try again later.';
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        type = ApiExceptionType.server;
        message = 'Server error. Please try again later.';
        break;
      default:
        type = ApiExceptionType.server;
        if (message.isEmpty) {
          message = 'An unexpected error occurred. Please try again.';
        }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      type: type,
      details: data is Map<String, dynamic> ? data : null,
    );
  }
}
