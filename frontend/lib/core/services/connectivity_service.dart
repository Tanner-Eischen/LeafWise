/// Core connectivity service for monitoring network status changes
/// Provides real-time connectivity monitoring and status checking capabilities
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/plant_identification/models/offline_plant_identification_models.dart';

/// Provider for the connectivity service singleton
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Provider for connectivity status stream
final connectivityStatusStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

/// Provider for current connectivity status
final currentConnectivityStatusProvider = FutureProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.getCurrentConnectivityStatus();
});

/// Main connectivity service class for monitoring network status
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final StreamController<ConnectivityStatus> _statusController = StreamController<ConnectivityStatus>.broadcast();

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get connectivityStream => _statusController.stream;

  /// Initialize connectivity monitoring
  /// Should be called during app startup to begin monitoring
  Future<void> initialize() async {
    try {
      // Get initial connectivity status
      final initialStatus = await getCurrentConnectivityStatus();
      _statusController.add(initialStatus);
      
      // Start listening to connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (ConnectivityResult result) => _handleConnectivityChange([result]),
        onError: _handleConnectivityError,
      );
    } catch (e) {
      _handleConnectivityError(e);
    }
  }

  /// Get current connectivity status
  /// Returns the current network connection state
  Future<ConnectivityStatus> getCurrentConnectivityStatus() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return _mapConnectivityResults([connectivityResult]);
    } catch (e) {
      // Default to offline if unable to check connectivity
      return const ConnectivityStatus.offline();
    }
  }

  /// Check if device is currently online
  /// Returns true if connected to any network (WiFi or mobile)
  Future<bool> isOnline() async {
    final status = await getCurrentConnectivityStatus();
    return status.when(
      offline: () => false,
      mobile: () => true,
      wifi: () => true,
    );
  }

  /// Check if device is currently offline
  /// Returns true if no network connection is available
  Future<bool> isOffline() async {
    final isConnected = await isOnline();
    return !isConnected;
  }

  /// Check if connected via WiFi
  /// Returns true if currently connected to WiFi network
  Future<bool> isWifiConnected() async {
    final status = await getCurrentConnectivityStatus();
    return status.when(
      offline: () => false,
      mobile: () => false,
      wifi: () => true,
    );
  }

  /// Check if connected via mobile data
  /// Returns true if currently connected to mobile network
  Future<bool> isMobileConnected() async {
    final status = await getCurrentConnectivityStatus();
    return status.when(
      offline: () => false,
      mobile: () => true,
      wifi: () => false,
    );
  }

  /// Handle connectivity changes from the platform
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    try {
      final status = _mapConnectivityResults(results);
      _statusController.add(status);
    } catch (e) {
      _handleConnectivityError(e);
    }
  }

  /// Handle connectivity monitoring errors
  void _handleConnectivityError(dynamic error) {
    // Log error and emit offline status as fallback
    _statusController.add(const ConnectivityStatus.offline());
  }

  /// Map platform connectivity results to app connectivity status
  ConnectivityStatus _mapConnectivityResults(List<ConnectivityResult> results) {
    // Handle multiple connectivity results (e.g., both WiFi and mobile)
    // Priority: WiFi > Mobile > Offline
    
    if (results.contains(ConnectivityResult.wifi)) {
      return const ConnectivityStatus.wifi();
    }
    
    if (results.contains(ConnectivityResult.mobile)) {
      return const ConnectivityStatus.mobile();
    }
    
    if (results.contains(ConnectivityResult.ethernet)) {
      // Treat ethernet as WiFi for our purposes
      return const ConnectivityStatus.wifi();
    }
    
    // No connection or unknown connection type
    return const ConnectivityStatus.offline();
  }

  /// Dispose of resources and stop monitoring
  /// Should be called when the service is no longer needed
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    await _statusController.close();
  }
}

/// Extension methods for ConnectivityStatus convenience
extension ConnectivityStatusExtension on ConnectivityStatus {
  /// Check if the status represents an online state
  bool get isOnline => when(
    offline: () => false,
    mobile: () => true,
    wifi: () => true,
  );

  /// Check if the status represents an offline state
  bool get isOffline => !isOnline;

  /// Check if connected via WiFi
  bool get isWifi => when(
    offline: () => false,
    mobile: () => false,
    wifi: () => true,
  );

  /// Check if connected via mobile data
  bool get isMobile => when(
    offline: () => false,
    mobile: () => true,
    wifi: () => false,
  );

  /// Get a human-readable description of the connectivity status
  String get description => when(
    offline: () => 'No internet connection',
    mobile: () => 'Connected via mobile data',
    wifi: () => 'Connected via WiFi',
  );

  /// Get an icon name for the connectivity status
  String get iconName => when(
    offline: () => 'signal_wifi_off',
    mobile: () => 'signal_cellular_alt',
    wifi: () => 'wifi',
  );
}