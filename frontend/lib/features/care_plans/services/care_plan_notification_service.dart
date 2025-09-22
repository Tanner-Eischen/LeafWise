import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:leafwise/features/care_plans/models/care_plan_models.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Care Plan Notification Service
///
/// Handles local notifications for care plan updates, reminders, and alerts.
/// Features:
/// - Care plan generation notifications
/// - Care activity reminders (watering, fertilizing)
/// - Plan expiration and update alerts
/// - Customizable notification scheduling
class CarePlanNotificationService {
  static final CarePlanNotificationService _instance =
      CarePlanNotificationService._internal();
  factory CarePlanNotificationService() => _instance;
  CarePlanNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Handle notification tap events
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Handle navigation based on payload
      // This would typically navigate to the relevant screen
      debugPrint('Notification tapped with payload: $payload');
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    await initialize();

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    bool granted = true;

    if (androidPlugin != null) {
      granted = await androidPlugin.requestNotificationsPermission() ?? false;
    }

    if (iosPlugin != null) {
      granted =
          await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return granted;
  }

  /// Show immediate notification for care plan generation
  Future<void> showPlanGeneratedNotification(CarePlan plan) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'care_plan_generated',
      'Care Plan Generated',
      channelDescription: 'Notifications when new care plans are generated',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      plan.id.hashCode,
      'New Care Plan Generated! 🌱',
      'Your personalized care plan is ready for review',
      details,
      payload: 'care_plan:${plan.id}',
    );
  }

  /// Schedule watering reminder notifications
  Future<void> scheduleWateringReminders(CarePlan plan) async {
    await initialize();

    final schedule = plan.watering;
    final intervalDays = schedule.intervalDays;

    // Calculate next watering dates based on interval
    final now = DateTime.now();
    final reminderTimes = <DateTime>[];
    for (int i = 0; i < 5; i++) {
      reminderTimes.add(now.add(Duration(days: intervalDays * (i + 1))));
    }

    for (int i = 0; i < reminderTimes.length; i++) {
      final reminderTime = reminderTimes[i];
      final notificationId = '${plan.id}_watering_$i'.hashCode;

      await _scheduleNotification(
        notificationId,
        'Time to Water! 💧',
        'Your plant needs ${schedule.amountMl}ml of water',
        reminderTime,
        'watering_reminder:${plan.id}',
        'watering_reminders',
        'Watering Reminders',
        'Reminders for plant watering schedules',
      );
    }
  }

  /// Schedule fertilizer reminder notifications
  Future<void> scheduleFertilizerReminders(CarePlan plan) async {
    await initialize();

    final schedule = plan.fertilizer;
    final intervalDays = schedule.intervalDays;

    // Calculate next fertilizer dates based on interval
    final now = DateTime.now();
    final reminderTimes = <DateTime>[];
    for (int i = 0; i < 3; i++) {
      reminderTimes.add(now.add(Duration(days: intervalDays * (i + 1))));
    }

    for (int i = 0; i < reminderTimes.length; i++) {
      final reminderTime = reminderTimes[i];
      final notificationId = '${plan.id}_fertilizer_$i'.hashCode;

      await _scheduleNotification(
        notificationId,
        'Fertilizer Time! 🌿',
        'Apply ${schedule.type} fertilizer to your plant',
        reminderTime,
        'fertilizer_reminder:${plan.id}',
        'fertilizer_reminders',
        'Fertilizer Reminders',
        'Reminders for plant fertilizer schedules',
      );
    }
  }

  /// Schedule care plan expiration alert
  Future<void> schedulePlanExpirationAlert(CarePlan plan) async {
    // Use validTo field instead of expiresAt
    if (plan.validTo == null) return;

    await initialize();

    // Schedule alert 24 hours before expiration
    final alertTime = plan.validTo!.subtract(const Duration(hours: 24));

    if (alertTime.isBefore(DateTime.now())) {
      return; // Already expired or too close
    }

    await _scheduleNotification(
      '${plan.id}_expiration'.hashCode,
      'Care Plan Expiring Soon ⚠️',
      'Your care plan expires tomorrow. Consider generating a new one.',
      alertTime,
      'plan_expiration:${plan.id}',
      'plan_alerts',
      'Plan Alerts',
      'Alerts for care plan status changes',
    );
  }

  /// Schedule daily care summary notification
  Future<void> scheduleDailyCareReminder() async {
    await initialize();

    // Schedule for 8 AM daily
    final now = DateTime.now();
    var scheduledTime = DateTime(now.year, now.month, now.day, 8, 0);

    // If it's already past 8 AM today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    await _scheduleNotification(
      'daily_care_summary'.hashCode,
      'Daily Plant Care 🌱',
      'Check your care plans and see what your plants need today',
      scheduledTime,
      'daily_summary',
      'daily_reminders',
      'Daily Reminders',
      'Daily plant care reminders',
      repeatInterval: RepeatInterval.daily,
    );
  }

  /// Show immediate alert notification
  Future<void> showAlertNotification(
    String title,
    String body,
    String payload,
  ) async {
    await initialize();

    const androidDetails = AndroidNotificationDetails(
      'care_plan_alerts',
      'Care Plan Alerts',
      channelDescription: 'Important alerts for care plan issues',
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      color: Colors.red,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      payload.hashCode,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Cancel all notifications for a specific care plan
  Future<void> cancelPlanNotifications(String planId) async {
    await initialize();

    // Cancel watering reminders
    for (int i = 0; i < 10; i++) {
      await _notifications.cancel('${planId}_watering_$i'.hashCode);
    }

    // Cancel fertilizer reminders
    for (int i = 0; i < 10; i++) {
      await _notifications.cancel('${planId}_fertilizer_$i'.hashCode);
    }

    // Cancel expiration alert
    await _notifications.cancel('${planId}_expiration'.hashCode);
  }

  /// Cancel all care plan notifications
  Future<void> cancelAllNotifications() async {
    await initialize();
    await _notifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    await initialize();
    return await _notifications.pendingNotificationRequests();
  }

  /// Schedule a notification with timezone support
  Future<void> _scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
    String payload,
    String channelId,
    String channelName,
    String channelDescription, {
    RepeatInterval? repeatInterval,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    if (repeatInterval != null) {
      await _notifications.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        details,
        payload: payload,
      );
    } else {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        details,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }



  /// Setup all notifications for a care plan
  Future<void> setupPlanNotifications(CarePlan plan) async {
    // Cancel existing notifications for this plan
    await cancelPlanNotifications(plan.id);

    // Schedule new notifications
    await scheduleWateringReminders(plan);
    await scheduleFertilizerReminders(plan);
    await schedulePlanExpirationAlert(plan);
  }

  /// Handle care plan acknowledgment
  Future<void> onPlanAcknowledged(CarePlan plan) async {
    // Show confirmation notification
    await _notifications.show(
      'plan_acknowledged_${plan.id}'.hashCode,
      'Care Plan Acknowledged ✅',
      'Your care plan is now active and reminders are set',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'plan_updates',
          'Plan Updates',
          channelDescription: 'Updates about care plan status',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'plan_acknowledged:${plan.id}',
    );

    // Setup ongoing reminders
    await setupPlanNotifications(plan);
  }

  /// Handle care activity completion
  Future<void> onCareActivityCompleted(
    String planId,
    String activityType,
    String plantName,
  ) async {
    await _notifications.show(
      'activity_completed_${planId}_$activityType'.hashCode,
      'Great Job! 🎉',
      'You completed $activityType for $plantName',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'activity_updates',
          'Activity Updates',
          channelDescription: 'Updates about completed care activities',
          importance: Importance.low,
          priority: Priority.low,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: false,
          presentSound: false,
        ),
      ),
      payload: 'activity_completed:$planId:$activityType',
    );
  }
}
