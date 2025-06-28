import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:plant_social/core/constants/app_constants.dart';
import 'package:plant_social/core/models/user.dart';
import 'package:plant_social/core/exceptions/api_exception.dart';
import 'package:plant_social/features/auth/models/auth_models.dart';
import 'package:plant_social/features/auth/repositories/auth_repository.dart';
import 'dart:convert';

// part 'auth_provider.g.dart'; // Commented out until code generation works

class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });
  
  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    bool? isInitialized,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.user == user &&
        other.isAuthenticated == isAuthenticated &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.isInitialized == isInitialized;
  }
  
  @override
  int get hashCode {
    return user.hashCode ^
        isAuthenticated.hashCode ^
        isLoading.hashCode ^
        error.hashCode ^
        isInitialized.hashCode;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage;

  AuthNotifier(this._authRepository, this._storage) : super(const AuthState()) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Check if user is already logged in
      final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
      final userDataJson = await _storage.read(key: AppConstants.userDataKey);
      
      if (accessToken != null && userDataJson != null) {
        try {
          final userData = json.decode(userDataJson) as Map<String, dynamic>;
          final user = User.fromJson(userData);
          
          // Verify token is still valid by fetching current user
          final currentUser = await _authRepository.getCurrentUser();
          
          state = state.copyWith(
            user: currentUser,
            isAuthenticated: true,
            isLoading: false,
            isInitialized: true,
            error: null,
          );
        } catch (e) {
          // Token is invalid, clear storage
          await _clearAuthData();
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            isInitialized: true,
            error: null,
          );
        }
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          isInitialized: true,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final loginRequest = LoginRequest(
        email: email,
        password: password,
      );
      
      final authResponse = await _authRepository.login(loginRequest);
      
      // Store tokens and user data
      await _storeAuthData(authResponse);
      
      state = state.copyWith(
        user: authResponse.user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      rethrow;
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final authResponse = await _authRepository.register(request);
      
      // Store tokens and user data
      await _storeAuthData(authResponse);
      
      state = state.copyWith(
        user: authResponse.user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Call logout endpoint
      await _authRepository.logout();
    } catch (e) {
      // Continue with logout even if API call fails
      print('Logout API call failed: $e');
    } finally {
      // Clear local data regardless of API call result
      await _clearAuthData();
      
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        isInitialized: true,
      );
    }
  }

  Future<void> refreshUser() async {
    if (!state.isAuthenticated) return;
    
    try {
      final user = await _authRepository.getCurrentUser();
      
      // Update stored user data
      await _storage.write(
        key: AppConstants.userDataKey,
        value: json.encode(user.toJson()),
      );
      
      state = state.copyWith(user: user);
    } catch (e) {
      // If refresh fails, user might need to re-authenticate
      print('Failed to refresh user: $e');
    }
  }

  Future<void> updateUser(User updatedUser) async {
    // Update stored user data
    await _storage.write(
      key: AppConstants.userDataKey,
      value: json.encode(updatedUser.toJson()),
    );
    
    state = state.copyWith(user: updatedUser);
  }

  Future<void> forgotPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _authRepository.forgotPassword(email);
      
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      rethrow;
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _authRepository.resetPassword(token, newPassword);
      
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      rethrow;
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _authRepository.changePassword(currentPassword, newPassword);
      
      state = state.copyWith(isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      rethrow;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      rethrow;
    }
  }

  Future<void> _storeAuthData(AuthResponse authResponse) async {
    await Future.wait([
      _storage.write(
        key: AppConstants.accessTokenKey,
        value: authResponse.accessToken,
      ),
      _storage.write(
        key: AppConstants.refreshTokenKey,
        value: authResponse.refreshToken,
      ),
      _storage.write(
        key: AppConstants.userDataKey,
        value: json.encode(authResponse.user.toJson()),
      ),
    ]);
  }

  Future<void> _clearAuthData() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
      _storage.delete(key: AppConstants.userDataKey),
    ]);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository, storage);
});

// Computed providers
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

final isAuthInitializedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isInitialized;
});