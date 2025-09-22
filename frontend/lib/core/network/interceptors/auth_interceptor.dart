import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:leafwise/core/constants/app_constants.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token from secure storage
    final accessToken = await _storage.read(key: AppConstants.accessTokenKey);

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors
    if (err.response?.statusCode == 401) {
      // Try to refresh token
      final refreshed = await _refreshToken();

      if (refreshed) {
        // Retry the original request
        final requestOptions = err.requestOptions;
        final accessToken = await _storage.read(
          key: AppConstants.accessTokenKey,
        );

        if (accessToken != null) {
          requestOptions.headers['Authorization'] = 'Bearer $accessToken';

          try {
            final dio = Dio();
            final response = await dio.fetch(requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // If retry fails, continue with original error
          }
        }
      }

      // If refresh failed or no refresh token, clear tokens and redirect to login
      await _clearTokens();
    }

    handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(
        key: AppConstants.refreshTokenKey,
      );

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final dio = Dio();
      final response = await dio.post(
        '${AppConstants.apiBaseUrl}/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final newAccessToken = data['access_token'];
        final newRefreshToken = data['refresh_token'];

        if (newAccessToken != null) {
          await _storage.write(
            key: AppConstants.accessTokenKey,
            value: newAccessToken,
          );
        }

        if (newRefreshToken != null) {
          await _storage.write(
            key: AppConstants.refreshTokenKey,
            value: newRefreshToken,
          );
        }

        return true;
      }
    } catch (e) {
      // Refresh failed
      print('Token refresh failed: $e');
    }

    return false;
  }

  Future<void> _clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.userDataKey),
    ]);
  }
}
