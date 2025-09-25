import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leafwise/core/constants/app_constants.dart';
import 'package:leafwise/core/models/user.dart';
import 'package:leafwise/features/auth/models/auth_models.dart';
import 'package:leafwise/features/auth/repositories/auth_repository.dart';

/// Web-safe storage wrapper that falls back to SharedPreferences on web
class WebSafeStorage {
  final FlutterSecureStorage? _secureStorage;
  SharedPreferences? _prefs;
  
  WebSafeStorage() : _secureStorage = kIsWeb ? null : _createSecureStorage();
  
  static FlutterSecureStorage? _createSecureStorage() {
    try {
      return const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      );
    } catch (e) {
      print('⚠️ Failed to create secure storage: $e');
      return null;
    }
  }
  
  Future<void> _ensurePrefsInitialized() async {
    if (kIsWeb && _prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }
  
  Future<String?> read({required String key}) async {
    try {
      if (kIsWeb) {
        await _ensurePrefsInitialized();
        return _prefs?.getString(key);
      } else {
        return await _secureStorage?.read(key: key);
      }
    } catch (e) {
      print('⚠️ Storage read error for key $key: $e');
      return null;
    }
  }
  
  Future<void> write({required String key, required String value}) async {
    try {
      if (kIsWeb) {
        await _ensurePrefsInitialized();
        await _prefs?.setString(key, value);
      } else {
        await _secureStorage?.write(key: key, value: value);
      }
    } catch (e) {
      print('⚠️ Storage write error for key $key: $e');
    }
  }
  
  Future<void> delete({required String key}) async {
    try {
      if (kIsWeb) {
        await _ensurePrefsInitialized();
        await _prefs?.remove(key);
      } else {
        await _secureStorage?.delete(key: key);
      }
    } catch (e) {
      print('⚠️ Storage delete error for key $key: $e');
    }
  }
  
  Future<void> deleteAll() async {
    try {
      if (kIsWeb) {
        await _ensurePrefsInitialized();
        final keys = _prefs?.getKeys().where((key) => 
          key.startsWith('leafwise_') || 
          key == AppConstants.accessTokenKey || 
          key == AppConstants.userDataKey
        ).toList() ?? [];
        for (final key in keys) {
          await _prefs?.remove(key);
        }
      } else {
        await _secureStorage?.deleteAll();
      }
    } catch (e) {
      print('⚠️ Storage deleteAll error: $e');
    }
  }
}

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
  final WebSafeStorage _storage;

  AuthNotifier(this._authRepository, this._storage) : super(const AuthState()) {
    // Initialize auth in microtask to avoid constructor issues
    Future.microtask(() => _initializeAuth());
  }

  Future<void> _initializeAuth() async {
    print('🔄 Starting auth initialization...');
    try {
      state = state.copyWith(isLoading: true);
      print('📱 Auth state set to loading');

      // Check if user is already logged in using web-safe storage
      print('🔍 Attempting to read from storage...');
      final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
      final userDataJson = await _storage.read(key: AppConstants.userDataKey);
      print('🔑 Token exists: ${accessToken != null}, User data exists: ${userDataJson != null}');

      if (accessToken != null && userDataJson != null) {
        try {
          final userData = json.decode(userDataJson) as Map<String, dynamic>;
          final user = User.fromJson(userData);
          print('👤 Parsed user data: ${user.email}');

          print('🌐 Attempting to verify token with backend...');
          //// Verify token is still valid by fetching current user with timeout
          final currentUser = await _authRepository.getCurrentUser().timeout(
            const Duration(seconds: 10),
          );
          print('✅ Token verification successful');

          state = state.copyWith(
            user: currentUser,
            isAuthenticated: true,
            isLoading: false,
            isInitialized: true,
            error: null,
          );
          print('✅ Auth initialization completed - user authenticated');
        } catch (e) {
          // Token is invalid or network timeout, clear storage and continue offline
          print('❌ Token verification failed: $e');
          await _clearAuthData();
          state = state.copyWith(
            isAuthenticated: false,
            isLoading: false,
            isInitialized: true,
            error: null,
          );
          print(
            '🔄 Auth initialization completed - user not authenticated (cleared data)',
          );
        }
      } else {
        print('🚫 No stored credentials found');
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
          isInitialized: true,
        );
        print('✅ Auth initialization completed - no stored credentials');
      }
    } catch (e) {
      print('💥 Auth initialization error: $e');
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: e.toString(),
      );
      print('❌ Auth initialization completed with error');
    }
  }

  Future<void> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final loginRequest = LoginRequest(username: email, password: password);

      final authResponse = await _authRepository.login(loginRequest);

      // Store tokens and user data
      await _storeAuthData(authResponse);

      state = state.copyWith(
        user: authResponse.user,
        isAuthenticated: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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

      // Update stored user data with error handling
      try {
        await _storage.write(
          key: AppConstants.userDataKey,
          value: json.encode(user.toJson()),
        );
        print('✅ User data updated in storage');
      } catch (storageError) {
        print('⚠️ Failed to update user data in secure storage: $storageError');
        // Continue with state update even if storage fails
      }

      state = state.copyWith(user: user);
    } catch (e) {
      // If refresh fails, user might need to re-authenticate
      print('Failed to refresh user: $e');
    }
  }

  Future<void> updateUser(User updatedUser) async {
    // Update stored user data with error handling
    try {
      await _storage.write(
        key: AppConstants.userDataKey,
        value: json.encode(updatedUser.toJson()),
      );
      print('✅ User data updated in storage');
    } catch (storageError) {
      print('⚠️ Failed to update user data in secure storage: $storageError');
      // Continue with state update even if storage fails
    }

    state = state.copyWith(user: updatedUser);
  }

  Future<void> _storeAuthData(AuthResponse authResponse) async {
    try {
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
      print('✅ Auth data stored successfully');
    } catch (storageError) {
      print(
        '⚠️ Failed to store auth data in secure storage (common on web): $storageError',
      );
      print('🔄 App will continue but user will need to re-login on refresh');
      // Don't rethrow - allow login to succeed even if storage fails
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await Future.wait([
        _storage.delete(key: AppConstants.accessTokenKey),
        _storage.delete(key: AppConstants.refreshTokenKey),
        _storage.delete(key: AppConstants.userDataKey),
      ]);
      print('✅ Auth data cleared successfully');
    } catch (storageError) {
      print('⚠️ Failed to clear auth data from secure storage: $storageError');
      // Don't rethrow - logout should succeed even if storage clear fails
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = WebSafeStorage();
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
