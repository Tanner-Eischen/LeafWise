import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('\n🚀 REQUEST[${options.method}] => PATH: ${options.path}');
      print('Headers:');
      options.headers.forEach((k, v) => print('  $k: $v'));
      
      if (options.queryParameters.isNotEmpty) {
        print('Query Parameters:');
        options.queryParameters.forEach((k, v) => print('  $k: $v'));
      }
      
      if (options.data != null) {
        print('Body: ${options.data}');
      }
      print('\n');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print('\n✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
      print('Data: ${response.data}');
      print('\n');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print('\n❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
      print('Error: ${err.error}');
      print('Message: ${err.message}');
      if (err.response?.data != null) {
        print('Response Data: ${err.response?.data}');
      }
      print('\n');
    }
    handler.next(err);
  }
}