import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leafwise/core/theme/app_theme.dart';
import 'package:leafwise/core/router/app_router.dart';
import 'package:leafwise/core/constants/app_constants.dart';
import 'package:leafwise/core/services/connectivity_service.dart';
import 'package:leafwise/core/services/preferences_service.dart';
import 'package:leafwise/features/plant_identification/providers/enhanced_plant_identification_provider.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline services
  await _initializeOfflineServices();

  runApp(const ProviderScope(child: LeafWiseApp()));
}

/// Initialize offline services and dependencies
Future<void> _initializeOfflineServices() async {
  try {
    // Initialize preferences service for login suggestions and persistence
    await PreferencesService.init();
    print('✅ PreferencesService initialized');
    
    // Note: Other services will be initialized through their providers when first accessed
    // This ensures proper dependency injection and lifecycle management
    print('🚀 Offline services will be initialized on first access');
  } catch (e) {
    print('❌ Error setting up offline services: $e');
  }
}

class LeafWiseApp extends ConsumerStatefulWidget {
  const LeafWiseApp({super.key});

  @override
  ConsumerState<LeafWiseApp> createState() => _LeafWiseAppState();
}

class _LeafWiseAppState extends ConsumerState<LeafWiseApp> {
  @override
  void initState() {
    super.initState();

    // Start connectivity monitoring and model initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startConnectivityMonitoring();
      _initializeModels();
    });
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    final connectivityService = ref.read(connectivityServiceProvider);

    // Listen to connectivity changes and update the enhanced provider
    connectivityService.connectivityStream.listen((status) {
      ref
          .read(enhancedPlantIdentificationStateProvider.notifier)
          .updateConnectivity(status);
    });
  }

  /// Initialize AI models during app startup
  Future<void> _initializeModels() async {
    try {
      // Load available models and local identifications
      await ref
          .read(enhancedPlantIdentificationStateProvider.notifier)
          .loadAvailableModels();
      await ref
          .read(enhancedPlantIdentificationStateProvider.notifier)
          .loadLocalIdentifications();

      print('Models and local data initialized successfully');
    } catch (e) {
      print('Error initializing models: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        // Add global error handling for offline services
        return _OfflineServiceErrorHandler(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

/// Global error handler for offline services
class _OfflineServiceErrorHandler extends ConsumerWidget {
  final Widget child;

  const _OfflineServiceErrorHandler({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(enhancedPlantIdentificationStateProvider);

    return Stack(
      children: [
        child,

        // Show global error overlay if there are critical offline service errors
        if (offlineState.error != null && _isCriticalError(offlineState.error!))
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Offline Service Error',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(offlineState.error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref
                                .read(
                                  enhancedPlantIdentificationStateProvider
                                      .notifier,
                                )
                                .clearError();
                          },
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Check if an error is critical and should be shown globally
  bool _isCriticalError(String error) {
    return error.toLowerCase().contains('critical') ||
        error.toLowerCase().contains('initialization failed') ||
        error.toLowerCase().contains('database error');
  }
}
