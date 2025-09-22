/// Core API provider for dependency injection
/// Provides centralized access to API service throughout the app
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:leafwise/core/network/api_client.dart';
import '../services/api_service.dart';

/// Provider for the API client
/// Used for making direct API requests throughout the app
final apiClientProvider = Provider<ApiClient>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage);
});

/// Provider for secure storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

/// Provider for API service - re-exported for convenience
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Provider for API client state management
final apiStateProvider = StateProvider<ApiState>((ref) {
  return const ApiState.idle();
});

/// API state management for loading states
class ApiState {
  final bool isLoading;
  final String? error;
  final String? message;

  const ApiState({required this.isLoading, this.error, this.message});

  const ApiState.idle() : this(isLoading: false);
  const ApiState.loading() : this(isLoading: true);
  const ApiState.error(String error) : this(isLoading: false, error: error);
  const ApiState.success(String message)
    : this(isLoading: false, message: message);

  ApiState copyWith({bool? isLoading, String? error, String? message}) {
    return ApiState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      message: message ?? this.message,
    );
  }
}
