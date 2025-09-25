class AppConstants {
  // App Info
  static const String appName = 'LeafWise';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'A plant-focused social messaging platform';

  // API Configuration
  static const String baseUrl = 'http://127.0.0.1:8000';
  static const String apiVersion = 'v1';
  static const String apiBaseUrl = '$baseUrl/api/$apiVersion';
  static const String wsBaseUrl = 'ws://127.0.0.1:8000/api/$apiVersion/ws';

  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';

  // Message Types
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeVideo = 'video';

  // Story Types
  static const String storyTypePhoto = 'photo';
  static const String storyTypeVideo = 'video';
  static const String storyTypePlantShowcase = 'plant_showcase';
  static const String storyTypePlantCare = 'plant_care';

  // Privacy Levels
  static const String privacyPublic = 'public';
  static const String privacyFriends = 'friends';
  static const String privacyCloseFriends = 'close_friends';

  // Friendship Status
  static const String friendshipPending = 'pending';
  static const String friendshipAccepted = 'accepted';
  static const String friendshipBlocked = 'blocked';

  // Media Constraints
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 50;
  static const int maxVideoDurationSeconds = 60;
  static const int storyDurationHours = 24;

  // Disappearing Message Timers (seconds)
  static const List<int> disappearTimers = [1, 3, 5, 10, 30, 60];

  // Plant Care Types
  static const String careTypeWatering = 'watering';
  static const String careTypeFertilizing = 'fertilizing';
  static const String careTypePruning = 'pruning';
  static const String careTypeRepotting = 'repotting';

  // Plant Difficulty Levels
  static const String difficultyEasy = 'easy';
  static const String difficultyModerate = 'moderate';
  static const String difficultyDifficult = 'difficult';

  // Error Messages
  static const String networkError = 'Network connection error';
  static const String serverError = 'Server error occurred';
  static const String authError = 'Authentication failed';
  static const String permissionError = 'Permission denied';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registrationSuccess = 'Registration successful';
  static const String messageSent = 'Message sent';
  static const String storyPosted = 'Story posted successfully';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxUsernameLength = 30;
  static const int maxDisplayNameLength = 50;
  static const int maxBioLength = 150;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Pagination
  static const int defaultPageSize = 20;
  static const int storiesPageSize = 10;
  static const int messagesPageSize = 50;
}
