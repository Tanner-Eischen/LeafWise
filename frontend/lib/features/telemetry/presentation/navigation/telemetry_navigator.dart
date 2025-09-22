import 'package:flutter/material.dart';
import 'package:leafwise/features/telemetry/presentation/screens/growth_photo_capture_screen.dart';
import 'package:leafwise/features/telemetry/presentation/screens/light_measurement_screen.dart';
import 'package:leafwise/features/telemetry/presentation/screens/telemetry_history_screen.dart';
import 'package:leafwise/features/telemetry/presentation/screens/telemetry_detail_screen.dart';
import 'package:leafwise/features/telemetry/presentation/telemetry_feature.dart';

/// Telemetry Navigator
///
/// This class provides navigation routes for the telemetry feature.
/// It defines the routes for the different telemetry screens and
/// handles navigation between them.
class TelemetryNavigator {
  /// Generate routes for the telemetry feature
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      '/telemetry': (context) => const TelemetryFeature(),
      '/telemetry/light-measurement': (context) =>
          const LightMeasurementScreen(),
      '/telemetry/growth-photo-capture': (context) =>
          const GrowthPhotoCaptureScreen(),
      '/telemetry/history': (context) => const TelemetryHistoryScreen(),
    };
  }

  /// Navigate to the telemetry feature main screen
  static void navigateToTelemetry(BuildContext context) {
    Navigator.pushNamed(context, '/telemetry');
  }

  /// Navigate to the light measurement screen
  static void navigateToLightMeasurement(BuildContext context) {
    Navigator.pushNamed(context, '/telemetry/light-measurement');
  }

  /// Navigate to the growth photo capture screen
  static void navigateToGrowthPhotoCapture(
    BuildContext context, {
    String? plantId,
  }) {
    if (plantId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GrowthPhotoCaptureScreen(plantId: plantId),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/telemetry/growth-photo-capture');
    }
  }

  /// Navigate to the telemetry detail screen
  static void navigateToTelemetryDetail(
    BuildContext context,
    String telemetryId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TelemetryDetailScreen(telemetryId: telemetryId),
      ),
    );
  }

  /// Navigate to the telemetry history screen
  static void navigateToTelemetryHistory(
    BuildContext context, {
    String? plantId,
  }) {
    if (plantId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TelemetryHistoryScreen(plantId: plantId),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/telemetry/history');
    }
  }
}
