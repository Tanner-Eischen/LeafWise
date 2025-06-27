/**
 * Core API service for handling HTTP requests and responses
 * Provides centralized API communication with error handling and authentication
 */

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../exceptions/api_exception.dart';

/**
 * Provider for the API service singleton
 */
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/**
 * Main API service class for handling all HTTP operations
 */
class ApiService {
  late final Dio _dio;
  
  ApiService() {
    _dio = Dio();
    _setupInterceptors();
  }

  /**
   * Configure Dio interceptors for logging and error handling
   */
  void _setupInterceptors() {
    _dio.options.baseUrl = 'http://localhost:8000/api';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /**
   * Generic GET request handler
   */
  Future<T> get<T>(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParameters);
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /**
   * Generic POST request handler
   */
  Future<T> post<T>(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(endpoint, data: data, queryParameters: queryParameters);
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /**
   * Generic PUT request handler
   */
  Future<T> put<T>(String endpoint, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(endpoint, data: data, queryParameters: queryParameters);
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /**
   * Generic DELETE request handler
   */
  Future<T> delete<T>(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(endpoint, queryParameters: queryParameters);
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /**
   * Upload file with multipart form data
   */
  Future<T> uploadFile<T>(String endpoint, String filePath, {Map<String, dynamic>? additionalData}) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...?additionalData,
      });
      
      final response = await _dio.post(endpoint, data: formData);
      return response.data as T;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}