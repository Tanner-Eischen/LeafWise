/**
 * Core storage service for handling local data persistence
 * Provides secure storage for user data, preferences, and cached content
 */

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/**
 * Provider for the storage service singleton
 */
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/**
 * Main storage service class for handling local data operations
 */
class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  SharedPreferences? _prefs;

  /**
   * Initialize shared preferences
   */
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /**
   * Store sensitive data securely (tokens, passwords)
   */
  Future<void> storeSecure(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /**
   * Retrieve sensitive data securely
   */
  Future<String?> getSecure(String key) async {
    return await _secureStorage.read(key: key);
  }

  /**
   * Delete sensitive data
   */
  Future<void> deleteSecure(String key) async {
    await _secureStorage.delete(key: key);
  }

  /**
   * Clear all secure storage
   */
  Future<void> clearSecure() async {
    await _secureStorage.deleteAll();
  }

  /**
   * Store regular preferences data
   */
  Future<bool> setString(String key, String value) async {
    await init();
    return _prefs!.setString(key, value);
  }

  /**
   * Get regular preferences data
   */
  Future<String?> getString(String key) async {
    await init();
    return _prefs!.getString(key);
  }

  /**
   * Store boolean preferences
   */
  Future<bool> setBool(String key, bool value) async {
    await init();
    return _prefs!.setBool(key, value);
  }

  /**
   * Get boolean preferences
   */
  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    await init();
    return _prefs!.getBool(key) ?? defaultValue;
  }

  /**
   * Store integer preferences
   */
  Future<bool> setInt(String key, int value) async {
    await init();
    return _prefs!.setInt(key, value);
  }

  /**
   * Get integer preferences
   */
  Future<int> getInt(String key, {int defaultValue = 0}) async {
    await init();
    return _prefs!.getInt(key) ?? defaultValue;
  }

  /**
   * Store list of strings
   */
  Future<bool> setStringList(String key, List<String> value) async {
    await init();
    return _prefs!.setStringList(key, value);
  }

  /**
   * Get list of strings
   */
  Future<List<String>> getStringList(String key) async {
    await init();
    return _prefs!.getStringList(key) ?? [];
  }

  /**
   * Remove a preference key
   */
  Future<bool> remove(String key) async {
    await init();
    return _prefs!.remove(key);
  }

  /**
   * Clear all preferences
   */
  Future<bool> clear() async {
    await init();
    return _prefs!.clear();
  }

  /**
   * Check if a key exists in preferences
   */
  Future<bool> containsKey(String key) async {
    await init();
    return _prefs!.containsKey(key);
  }
}