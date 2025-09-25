import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/core/models/user.dart';
import 'package:leafwise/core/network/api_client.dart';
import 'package:leafwise/features/auth/models/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<User> getCurrentUser();
  Future<MessageResponse> forgotPassword(String email);
  Future<MessageResponse> resetPassword(String token, String newPassword);
  Future<MessageResponse> changePassword(
    String currentPassword,
    String newPassword,
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      print('🔐 Starting login process...');
      // Backend expects JSON data with 'username' field
      final jsonData = {
        'username': request
            .username, // Backend uses 'username' field for email/username
        'password': request.password,
      };

      // Step 1: Login and get tokens
      print('🚀 Calling /auth/login...');
      final loginResponse = await _apiClient.post('/auth/login', data: jsonData);
      print('✅ Login response received: ${loginResponse.statusCode}');
      
      // Extract token data from response
      final tokenData = loginResponse.data;
      final accessToken = tokenData['access_token'] as String;
      final refreshToken = tokenData['refresh_token'] as String;
      final tokenType = tokenData['token_type'] as String? ?? 'bearer';
      print('🔑 Tokens extracted successfully');
      
      // Step 2: Use the access token to get user data with explicit authorization header
      print('👤 Calling /auth/me with token...');
      final userResponse = await _apiClient.get(
        '/auth/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );
      print('✅ User data response received: ${userResponse.statusCode}');
      print('📄 User data: ${userResponse.data}');
      
      final user = User.fromJson(userResponse.data);
      print('👤 User object created: ${user.email}');
      
      // Step 3: Return properly structured AuthResponse
      final authResponse = AuthResponse(
        accessToken: accessToken,
        refreshToken: refreshToken,
        user: user,
        tokenType: tokenType,
        expiresIn: tokenData['expires_in'] as int?,
      );
      print('🎉 AuthResponse created successfully');
      return authResponse;
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      // Send only the essential required fields to avoid validation issues
      final data = {
        'email': request.email,
        'username': request.username,
        'password': request.password,
        'confirm_password': request.confirmPassword,
        'display_name': request.displayName ?? request.username,
        'is_private': false,
        'allow_plant_id_requests': true,
      };

      final response = await _apiClient.post('/auth/register', data: data);

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> refreshToken(String refreshToken) async {
    try {
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _apiClient.post(
        '/auth/refresh',
        data: request.toJson(),
      );

      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MessageResponse> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequest(email: email);
      final response = await _apiClient.post(
        '/auth/forgot-password',
        data: request.toJson(),
      );

      return MessageResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MessageResponse> resetPassword(
    String token,
    String newPassword,
  ) async {
    try {
      final request = ResetPasswordRequest(
        token: token,
        newPassword: newPassword,
        confirmPassword: newPassword,
      );
      final response = await _apiClient.post(
        '/auth/reset-password',
        data: request.toJson(),
      );

      return MessageResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MessageResponse> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: newPassword,
      );
      final response = await _apiClient.post(
        '/auth/change-password',
        data: request.toJson(),
      );

      return MessageResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}

// Provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(apiClient);
});
