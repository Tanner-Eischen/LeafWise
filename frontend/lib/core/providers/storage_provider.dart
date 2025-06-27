/**
 * Core storage provider for dependency injection
 * Provides centralized access to storage service throughout the app
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/**
 * Provider for storage service - re-exported for convenience
 */
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/**
 * Provider for user preferences state
 */
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return UserPreferencesNotifier(storageService);
});

/**
 * User preferences state model
 */
class UserPreferences {
  final bool isDarkMode;
  final String language;
  final bool notificationsEnabled;
  final bool locationEnabled;

  const UserPreferences({
    this.isDarkMode = false,
    this.language = 'en',
    this.notificationsEnabled = true,
    this.locationEnabled = false,
  });

  UserPreferences copyWith({
    bool? isDarkMode,
    String? language,
    bool? notificationsEnabled,
    bool? locationEnabled,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      language: language ?? this.language,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      locationEnabled: locationEnabled ?? this.locationEnabled,
    );
  }
}

/**
 * User preferences state notifier
 */
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final StorageService _storageService;

  UserPreferencesNotifier(this._storageService) : super(const UserPreferences()) {
    _loadPreferences();
  }

  /**
   * Load preferences from storage
   */
  Future<void> _loadPreferences() async {
    final isDarkMode = await _storageService.getBool('isDarkMode');
    final language = await _storageService.getString('language') ?? 'en';
    final notificationsEnabled = await _storageService.getBool('notificationsEnabled', defaultValue: true);
    final locationEnabled = await _storageService.getBool('locationEnabled');

    state = UserPreferences(
      isDarkMode: isDarkMode,
      language: language,
      notificationsEnabled: notificationsEnabled,
      locationEnabled: locationEnabled,
    );
  }

  /**
   * Update dark mode preference
   */
  Future<void> setDarkMode(bool isDarkMode) async {
    await _storageService.setBool('isDarkMode', isDarkMode);
    state = state.copyWith(isDarkMode: isDarkMode);
  }

  /**
   * Update language preference
   */
  Future<void> setLanguage(String language) async {
    await _storageService.setString('language', language);
    state = state.copyWith(language: language);
  }

  /**
   * Update notifications preference
   */
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _storageService.setBool('notificationsEnabled', enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  /**
   * Update location preference
   */
  Future<void> setLocationEnabled(bool enabled) async {
    await _storageService.setBool('locationEnabled', enabled);
    state = state.copyWith(locationEnabled: enabled);
  }
}