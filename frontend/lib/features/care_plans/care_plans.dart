/// Care Plans Feature Export
///
/// Main export file for the Context-Aware Care Plans v2 feature.
/// Provides centralized access to all care plan components including:
/// - Models and data structures
/// - API services and providers
/// - UI screens and widgets
/// - Notification services
/// - Integration utilities
library;

import 'package:leafwise/features/care_plans/models/care_plan_models.dart';
import 'package:leafwise/features/care_plans/services/care_plan_notification_service.dart';


// Models
export 'models/care_plan_models.dart';
export 'models/care_plan_status.dart';

// Services
export 'services/care_plan_api_service.dart';
export 'services/care_plan_notification_service.dart';

// Providers
export 'providers/care_plan_provider.dart';

// Screens
export 'presentation/screens/care_plan_display_screen.dart';
export 'presentation/screens/care_plan_generation_screen.dart';
export 'presentation/screens/care_plan_history_screen.dart';

// Widgets
export 'presentation/widgets/care_plan_card.dart';
export 'presentation/widgets/care_plan_rationale_widget.dart';

/// Care Plans Feature Constants
class CarePlansFeature {
  static const String featureName = 'Context-Aware Care Plans v2';
  static const String version = '2.0.0';

  // Route names
  static const String displayRoute = '/care-plans';
  static const String generationRoute = '/care-plans/generate';
  static const String historyRoute = '/care-plans/history';

  // Notification channels
  static const String planGeneratedChannel = 'care_plan_generated';
  static const String wateringRemindersChannel = 'watering_reminders';
  static const String fertilizerRemindersChannel = 'fertilizer_reminders';
  static const String planAlertsChannel = 'plan_alerts';
  static const String dailyRemindersChannel = 'daily_reminders';

  // Cache keys
  static const String activePlansCache = 'active_care_plans';
  static const String planHistoryCache = 'care_plan_history';
  static const String notificationsCache = 'care_plan_notifications';

  // API endpoints
  static const String generateEndpoint = '/api/v1/care-plans/generate';
  static const String acknowledgeEndpoint =
      '/api/v1/care-plans/{id}/acknowledge';
  static const String historyEndpoint = '/api/v1/care-plans/history';
  static const String notificationsEndpoint =
      '/api/v1/care-plans/notifications';

  // Feature flags
  static const bool enableOfflineMode = true;
  static const bool enableNotifications = true;
  static const bool enableRationale = true;
  static const bool enableComparison = true;

  // Configuration
  static const int maxHistoryItems = 100;
  static const int defaultPageSize = 20;
  static const Duration cacheExpiration = Duration(hours: 1);
  static const Duration notificationScheduleWindow = Duration(days: 30);
}

/// Care Plans Feature Utilities
class CarePlansUtils {
  /// Initialize the care plans feature
  static Future<void> initialize() async {
    // Initialize notification service
    final notificationService = CarePlanNotificationService();
    await notificationService.initialize();
    await notificationService.requestPermissions();

    // Setup daily care reminders
    await notificationService.scheduleDailyCareReminder();
  }

  /// Get feature status
  static Map<String, dynamic> getFeatureStatus() {
    return {
      'name': CarePlansFeature.featureName,
      'version': CarePlansFeature.version,
      'offline_mode': CarePlansFeature.enableOfflineMode,
      'notifications': CarePlansFeature.enableNotifications,
      'rationale': CarePlansFeature.enableRationale,
      'comparison': CarePlansFeature.enableComparison,
    };
  }

  /// Validate care plan data
  static bool validateCarePlan(CarePlan plan) {
    if (plan.id.isEmpty) return false;
    if (plan.plantId.isEmpty) return false;
    if (plan.createdAt.isAfter(DateTime.now())) return false;

    // Validate schedules
    final wateringSchedule = plan.watering;
    if (wateringSchedule.intervalDays <= 0) return false;
    if (wateringSchedule.amountMl <= 0) return false;

    final fertilizerSchedule = plan.fertilizer;
    if (fertilizerSchedule.intervalDays <= 0) return false;
    if (fertilizerSchedule.type.isEmpty) return false;

    final lightTarget = plan.lightTarget;
    if (lightTarget.ppfdMin <= 0 || lightTarget.ppfdMax <= 0) return false;

    return true;
  }

  /// Format care plan summary
  static String formatCarePlanHistory(CarePlan plan) {
    final buffer = StringBuffer();

    final wateringSchedule = plan.watering;
    buffer.write('Water: every ${wateringSchedule.intervalDays} days ');
    buffer.write('(${wateringSchedule.amountMl}ml)');

    if (buffer.isNotEmpty) buffer.write(' • ');
    final fertilizerSchedule = plan.fertilizer;
    buffer.write(
      'Fertilize: every ${fertilizerSchedule.intervalDays} days ',
    );
    buffer.write('(${fertilizerSchedule.type})');

    if (buffer.isNotEmpty) buffer.write(' • ');
    final lightTarget = plan.lightTarget;
    buffer.write('Light: ${lightTarget.ppfdMin}-${lightTarget.ppfdMax} PPFD');

    return buffer.toString();
  }

  /// Calculate plan effectiveness score
  static double calculateEffectivenessScore(CarePlan plan) {
    double score = 0.0;
    int factors = 0;

    // Rationale confidence
    score += plan.rationale.confidence;
    factors++;

    // Schedule completeness
    score += 0.8; // High importance for watering
    factors++;

    score += 0.6; // Medium importance for fertilizer
    factors++;

    score += 0.7; // High importance for light
    factors++;

    // Status bonus
    switch (plan.status) {
      case CarePlanStatus.active:
        score += 0.9;
        factors++;
        break;
      case CarePlanStatus.acknowledged:
        score += 0.7;
        factors++;
        break;
      case CarePlanStatus.pending:
        score += 0.5;
        factors++;
        break;
      default:
        score += 0.3;
        factors++;
    }

    return factors > 0 ? score / factors : 0.0;
  }

  /// Get next care action
  static String? getNextCareAction(CarePlan plan) {
    final now = DateTime.now();

    // Check watering schedule
    final wateringSchedule = plan.watering;
    if (now.isAfter(wateringSchedule.nextDue)) {
      return 'Water your plant with ${wateringSchedule.amountMl}ml';
    }

    // Check fertilizer schedule
    final fertilizerSchedule = plan.fertilizer;
    if (fertilizerSchedule.nextDue != null &&
        now.isAfter(fertilizerSchedule.nextDue!)) {
      return 'Apply ${fertilizerSchedule.type} fertilizer';
    }

    // Check light requirements
    final lightTarget = plan.lightTarget;
    return 'Ensure light is within ${lightTarget.ppfdMin}-${lightTarget.ppfdMax} PPFD';
  }

  /// Clean up expired data
  static Future<void> cleanupExpiredData() async {
    // This would clean up old cache entries, expired plans, etc.
    // Implementation would depend on the storage mechanism
  }
}
