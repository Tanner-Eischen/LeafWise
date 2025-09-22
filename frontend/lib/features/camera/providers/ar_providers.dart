/// AR Providers
///
/// This file contains providers for AR-related services and state management.
/// Centralizes access to AR services throughout the application.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/core/providers/api_provider.dart';
import 'package:leafwise/features/camera/services/ar_seasonal_service.dart';

/// Provider for the AR seasonal service
/// Used for accessing AR seasonal overlays, growth projections, and time-lapse previews
final arSeasonalServiceProvider = Provider<ARSeasonalService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ARSeasonalService(apiClient);
});
