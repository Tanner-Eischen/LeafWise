/// Core API service for handling HTTP requests and responses
/// Provides centralized API communication with error handling and authentication
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/api_exception.dart';

/// Provider for the API service singleton
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Main API service class for handling all HTTP operations
class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio();
    _setupInterceptors();
  }

  /// Configure Dio interceptors for logging and error handling
  void _setupInterceptors() {
    _dio.options.baseUrl = 'http://localhost:8000/api';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Generic GET request handler
  Future<T> get<T>(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException(
        message: e.message ?? 'Unknown error occurred',
        statusCode: e.response?.statusCode ?? 0,
        type: _getExceptionType(e),
      );
    }
  }

  /// Generic POST request handler
  Future<T> post<T>(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(endpoint, data: data, queryParameters: queryParameters);
      return response.data as T;
    } on DioException catch (e) {
      throw _createApiException(e);
    }
  }

  /// Generic PUT request handler
  Future<T> put<T>(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(endpoint, data: data, queryParameters: queryParameters);
      return response.data as T;
    } on DioException catch (e) {
      throw _createApiException(e);
    }
  }

  /// Generic DELETE request handler
  Future<T> delete<T>(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(endpoint, queryParameters: queryParameters);
      return response.data as T;
    } on DioException catch (e) {
      throw _createApiException(e);
    }
  }

  /// Upload file with multipart form data
  Future<T> uploadFile<T>(String endpoint, String filePath, {Map<String, dynamic>? additionalData}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });
      
      final response = await _dio.post(endpoint, data: formData);
      return response.data as T;
    } on DioException catch (e) {
      throw _createApiException(e);
    }
  }

  /// Helper method to create ApiException from DioException
  ApiException _createApiException(DioException e) {
    return ApiException(
      message: e.message ?? 'Unknown error occurred',
      statusCode: e.response?.statusCode ?? 0,
      type: _getExceptionType(e),
    );
  }

  /// Helper method to determine exception type from DioException
  ApiExceptionType _getExceptionType(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiExceptionType.timeout;
      case DioExceptionType.connectionError:
        return ApiExceptionType.network;
      case DioExceptionType.cancel:
        return ApiExceptionType.cancel;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        if (statusCode >= 400 && statusCode < 500) {
          switch (statusCode) {
            case 400:
              return ApiExceptionType.badRequest;
            case 401:
              return ApiExceptionType.unauthorized;
            case 403:
              return ApiExceptionType.forbidden;
            case 404:
              return ApiExceptionType.notFound;
            case 409:
              return ApiExceptionType.conflict;
            case 422:
              return ApiExceptionType.validation;
            case 429:
              return ApiExceptionType.tooManyRequests;
            default:
              return ApiExceptionType.badRequest;
          }
        } else if (statusCode >= 500) {
          return ApiExceptionType.server;
        }
        return ApiExceptionType.unknown;
      default:
        return ApiExceptionType.unknown;
    }
  }
}