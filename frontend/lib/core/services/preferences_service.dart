import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences and login field suggestions
/// Handles storing and retrieving email suggestions, remember me state, and other user preferences
class PreferencesService {
  static const String _emailSuggestionsKey = 'email_suggestions';
  static const String _rememberMeKey = 'remember_me';
  static const String _lastEmailKey = 'last_email';
  static const String _maxSuggestions = 'max_suggestions';
  
  static const int maxEmailSuggestions = 5;
  
  static SharedPreferences? _prefs;
  
  /// Initialize the preferences service
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Get the SharedPreferences instance
  static SharedPreferences get _preferences {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call init() first.');
    }
    return _prefs!;
  }
  
  /// Save an email to the suggestions list
  /// Adds the email to the top of the list and removes duplicates
  static Future<void> saveEmailSuggestion(String email) async {
    if (email.isEmpty) return;
    
    final suggestions = getEmailSuggestions();
    
    // Remove if already exists to avoid duplicates
    suggestions.remove(email);
    
    // Add to the beginning of the list
    suggestions.insert(0, email);
    
    // Keep only the maximum number of suggestions
    if (suggestions.length > maxEmailSuggestions) {
      suggestions.removeRange(maxEmailSuggestions, suggestions.length);
    }
    
    await _preferences.setStringList(_emailSuggestionsKey, suggestions);
    await _preferences.setString(_lastEmailKey, email);
  }
  
  /// Get the list of email suggestions
  static List<String> getEmailSuggestions() {
    return _preferences.getStringList(_emailSuggestionsKey) ?? [];
  }
  
  /// Get the last used email
  static String? getLastEmail() {
    return _preferences.getString(_lastEmailKey);
  }
  
  /// Clear all email suggestions
  static Future<void> clearEmailSuggestions() async {
    await _preferences.remove(_emailSuggestionsKey);
    await _preferences.remove(_lastEmailKey);
  }
  
  /// Save the remember me state
  static Future<void> setRememberMe(bool rememberMe) async {
    await _preferences.setBool(_rememberMeKey, rememberMe);
  }
  
  /// Get the remember me state
  static bool getRememberMe() {
    return _preferences.getBool(_rememberMeKey) ?? false;
  }
  
  /// Clear the remember me state
  static Future<void> clearRememberMe() async {
    await _preferences.remove(_rememberMeKey);
  }
  
  /// Remove a specific email from suggestions
  static Future<void> removeEmailSuggestion(String email) async {
    final suggestions = getEmailSuggestions();
    suggestions.remove(email);
    await _preferences.setStringList(_emailSuggestionsKey, suggestions);
  }
  
  /// Check if an email exists in suggestions
  static bool hasEmailSuggestion(String email) {
    return getEmailSuggestions().contains(email);
  }
  
  /// Get filtered email suggestions based on query
  static List<String> getFilteredEmailSuggestions(String query) {
    if (query.isEmpty) return getEmailSuggestions();
    
    final suggestions = getEmailSuggestions();
    return suggestions
        .where((email) => email.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
  
  /// Clear all preferences (useful for logout or reset)
  static Future<void> clearAll() async {
    await clearEmailSuggestions();
    await clearRememberMe();
  }
}