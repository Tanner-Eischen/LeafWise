import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/core/models/user.dart';
import 'package:plant_social/core/network/api_client.dart';
import 'package:plant_social/features/auth/models/auth_models.dart';

abstract class AuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<AuthResponse> refreshToken(String refreshToken);
  Future<User> getCurrentUser();
  Future<MessageResponse> forgotPassword(String email);
  Future<MessageResponse> resetPassword(String token, String newPassword);
  Future<MessageResponse> changePassword(String currentPassword, String newPassword);
  Future<MessageResponse> verifyEmail(String token);
  Future<MessageResponse> resendVerification(String email);
  Future<TokenValidationResponse> validateToken(String token);
}

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient _apiClient;

  AuthRepositoryImpl(this._apiClient);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: request.toJson(),
      );
      
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: request.toJson(),
      );
      
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
  Future<MessageResponse> resetPassword(String token, String newPassword) async {
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
  Future<MessageResponse> changePassword(String currentPassword, String newPassword) async {
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

  @override
  Future<MessageResponse> verifyEmail(String token) async {
    try {
      final request = VerifyEmailRequest(token: token);
      final response = await _apiClient.post(
        '/auth/verify-email',
        data: request.toJson(),
      );
      
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<MessageResponse> resendVerification(String email) async {
    try {
      final request = ResendVerificationRequest(email: email);
      final response = await _apiClient.post(
        '/auth/resend-verification',
        data: request.toJson(),
      );
      
      return MessageResponse.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TokenValidationResponse> validateToken(String token) async {
    try {
      final response = await _apiClient.post(
        '/auth/validate-token',
        data: {'token': token},
      );
      
      return TokenValidationResponse.fromJson(response.data);
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