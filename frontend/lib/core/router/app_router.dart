import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:leafwise/features/auth/presentation/screens/login_screen.dart';
import 'package:leafwise/features/auth/presentation/screens/register_screen.dart';
import 'package:leafwise/features/auth/presentation/screens/splash_screen.dart';
import 'package:leafwise/features/home/presentation/screens/main_screen.dart';
import 'package:leafwise/features/camera/presentation/screens/camera_screen.dart';
import 'package:leafwise/features/chat/presentation/screens/chat_screen.dart';
import 'package:leafwise/features/chat/presentation/screens/conversation_screen.dart';
import 'package:leafwise/features/stories/presentation/screens/story_viewer_screen.dart';
import 'package:leafwise/features/stories/presentation/screens/story_creation_screen.dart';
import 'package:leafwise/features/profile/presentation/screens/profile_screen.dart';
import 'package:leafwise/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:leafwise/features/friends/presentation/screens/friends_screen.dart';
import 'package:leafwise/features/friends/presentation/screens/add_friends_screen.dart';
import 'package:leafwise/features/plant/presentation/screens/plant_features_screen.dart';
import 'package:leafwise/features/telemetry/screens/telemetry_tile_demo_screen.dart';
import 'package:leafwise/features/telemetry/presentation/telemetry_feature.dart';
import 'package:leafwise/features/telemetry/presentation/screens/telemetry_history_screen.dart';
import 'package:leafwise/features/telemetry/presentation/screens/telemetry_detail_screen.dart';
import 'package:leafwise/features/telemetry/presentation/screens/light_measurement_screen.dart';
import 'package:leafwise/features/telemetry/presentation/screens/growth_photo_capture_screen.dart';
import 'package:leafwise/features/plant_care/presentation/screens/add_plant_screen.dart';
import 'package:leafwise/features/plant_care/presentation/screens/plant_care_dashboard_screen.dart';
import 'package:leafwise/features/plant_care/presentation/screens/plant_detail_screen.dart';
import 'package:leafwise/features/plant_care/presentation/screens/care_logs_screen.dart';
import 'package:leafwise/features/plant_care/presentation/screens/care_reminders_screen.dart';
import 'package:leafwise/features/plant_identification/presentation/screens/plant_identification_screen.dart';
import 'package:leafwise/features/plant_identification/presentation/screens/plant_search_screen.dart';
import 'package:leafwise/features/plant_identification/presentation/screens/plant_species_detail_screen.dart';
import 'package:leafwise/features/plant_identification/presentation/screens/plant_identification_history_screen.dart';
import 'package:leafwise/features/plant_community/presentation/screens/plant_community_screen.dart';
import 'package:leafwise/features/plant_community/presentation/screens/plant_questions_screen.dart';
import 'package:leafwise/features/plant_community/presentation/screens/plant_trades_screen.dart';
import 'package:leafwise/features/plant_community/presentation/screens/trending_topics_screen.dart';
import 'package:leafwise/features/care_plans/presentation/screens/care_plan_generation_screen.dart';
import 'package:leafwise/features/care_plans/presentation/screens/care_plan_display_screen.dart';
import 'package:leafwise/features/care_plans/presentation/screens/care_plan_history_screen.dart';
import 'package:leafwise/features/auth/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.isAuthenticated;
      final isInitialized = authState.isInitialized;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      print('🔄 Router redirect - Location: ${state.matchedLocation}');
      print('🔄 Router redirect - isLoggedIn: $isLoggedIn, isInitialized: $isInitialized');
      print('🔄 Router redirect - isLoggingIn: $isLoggingIn');

      // Don't redirect from splash until auth is initialized
      if (state.matchedLocation == '/splash' && !isInitialized) {
        print('🔄 Router redirect - Staying on splash (auth not initialized)');
        return null;
      }

      // If auth is initialized and on splash, redirect based on auth status
      if (state.matchedLocation == '/splash' && isInitialized) {
        final destination = isLoggedIn ? '/home' : '/login';
        print('🔄 Router redirect - Auth initialized, redirecting from splash to $destination');
        return destination;
      }

      // If not logged in and not on auth screens, redirect to login
      if (!isLoggedIn && !isLoggingIn && state.matchedLocation != '/splash') {
        print('🔄 Router redirect - Redirecting to /login');
        return '/login';
      }

      // If logged in and on auth screens, redirect to home
      if (isLoggedIn && isLoggingIn) {
        print('🔄 Router redirect - Redirecting to /home');
        return '/home';
      }

      print('🔄 Router redirect - No redirect needed');
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (BuildContext context, GoRouterState state) =>
            const RegisterScreen(),
      ),

      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) =>
            const MainScreen(),
        routes: [
          // Camera Route
          GoRoute(
            path: 'camera',
            name: 'camera',
            builder: (context, state) => const CameraScreen(),
            routes: [
              GoRoute(
                path: 'story-creation',
                name: 'story-creation',
                builder: (context, state) {
                  final imagePath = state.uri.queryParameters['imagePath'];
                  return StoryCreationScreen(imagePath: imagePath);
                },
              ),
            ],
          ),

          // Chat Routes
          GoRoute(
            path: 'chat',
            name: 'chat',
            builder: (context, state) => const ChatScreen(),
            routes: [
              GoRoute(
                path: 'conversation/:userId',
                name: 'conversation',
                builder: (context, state) {
                  final userId = state.pathParameters['userId']!;
                  final userName = state.uri.queryParameters['userName'];
                  return ConversationScreen(userId: userId, userName: userName);
                },
              ),
            ],
          ),

          // Stories Routes
          GoRoute(
            path: 'story/:storyId',
            name: 'story-viewer',
            builder: (context, state) {
              final storyId = state.pathParameters['storyId']!;
              final userId = state.uri.queryParameters['userId'];
              return StoryViewerScreen(storyId: storyId, userId: userId);
            },
          ),

          // Profile Routes
          GoRoute(
            path: 'profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) => const ProfileEditScreen(),
              ),
            ],
          ),

          // Friends Routes
          GoRoute(
            path: 'friends',
            name: 'friends',
            builder: (context, state) => const FriendsScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-friends',
                builder: (context, state) => const AddFriendsScreen(),
              ),
            ],
          ),

          // Plant Features Routes
          GoRoute(
            path: 'plants',
            name: 'plants',
            builder: (context, state) => const PlantFeaturesScreen(),
            routes: [
              // Plant Care Routes
              GoRoute(
                path: 'care',
                name: 'plant-care',
                builder: (context, state) => const PlantCareDashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    name: 'add-plant',
                    builder: (context, state) => const AddPlantScreen(),
                  ),
                  GoRoute(
                    path: ':plantId',
                    name: 'plant-detail',
                    builder: (context, state) {
                      final plantId = state.pathParameters['plantId']!;
                      return PlantDetailScreen(plantId: plantId);
                    },
                    routes: [
                      GoRoute(
                        path: 'logs',
                        name: 'care-logs',
                        builder: (context, state) {
                          final plantId = state.pathParameters['plantId']!;
                          return CareLogsScreen(plantId: plantId);
                        },
                      ),
                      GoRoute(
                        path: 'reminders',
                        name: 'care-reminders',
                        builder: (context, state) {
                          final plantId = state.pathParameters['plantId']!;
                          return CareRemindersScreen(plantId: plantId);
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Plant Identification Routes
              GoRoute(
                path: 'identify',
                name: 'plant-identification',
                builder: (context, state) => const PlantIdentificationScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    name: 'plant-search',
                    builder: (context, state) => const PlantSearchScreen(),
                  ),
                  GoRoute(
                    path: 'history',
                    name: 'identification-history',
                    builder: (context, state) => const PlantIdentificationHistoryScreen(),
                  ),
                  GoRoute(
                    path: 'species/:speciesId',
                    name: 'plant-species-detail',
                    builder: (context, state) {
                      final speciesId = state.pathParameters['speciesId']!;
                      return PlantSpeciesDetailScreen(speciesId: speciesId);
                    },
                  ),
                ],
              ),

              // Plant Community Routes
              GoRoute(
                path: 'community',
                name: 'plant-community',
                builder: (context, state) => const PlantCommunityScreen(),
                routes: [
                  GoRoute(
                    path: 'questions',
                    name: 'plant-questions',
                    builder: (context, state) => const PlantQuestionsScreen(),
                  ),
                  GoRoute(
                    path: 'trades',
                    name: 'plant-trades',
                    builder: (context, state) => const PlantTradesScreen(),
                  ),
                  GoRoute(
                    path: 'trending',
                    name: 'trending-topics',
                    builder: (context, state) => const TrendingTopicsScreen(),
                  ),
                ],
              ),

              // Care Plans Routes
              GoRoute(
                path: 'care-plans',
                name: 'care-plans',
                builder: (context, state) => const CarePlanHistoryScreen(),
                routes: [
                  GoRoute(
                    path: 'generate',
                    name: 'generate-care-plan',
                    builder: (context, state) {
                      final plantId = state.uri.queryParameters['plantId'];
                      return CarePlanGenerationScreen(userPlantId: plantId);
                    },
                  ),
                  GoRoute(
                    path: ':planId',
                    name: 'care-plan-detail',
                    builder: (context, state) {
                      final planId = state.pathParameters['planId']!;
                      return CarePlanDisplayScreen(userPlantId: planId);
                    },
                  ),
                ],
              ),

              // Plant-specific telemetry route
              GoRoute(
                path: ':plantId/telemetry',
                name: 'plant-telemetry',
                redirect: (context, state) {
                  final authState = ref.read(authProvider);
                  if (!authState.isAuthenticated) {
                    return '/login';
                  }
                  // Check if user has telemetry access (expert, admin, or moderator)
                  final user = authState.user;
                  if (user != null && !user.hasTelemetryAccess) {
                    // Redirect to plants page if user doesn't have telemetry access
                    return '/home/plants';
                  }
                  return null; // Allow access
                },
                builder: (context, state) {
                  final plantId = state.pathParameters['plantId']!;
                  return TelemetryHistoryScreen(plantId: plantId);
                },
                routes: [
                  // Plant telemetry detail route
                  GoRoute(
                    path: ':telemetryId',
                    name: 'plant-telemetry-detail',
                    builder: (context, state) {
                      final telemetryId = state.pathParameters['telemetryId']!;
                      return TelemetryDetailScreen(telemetryId: telemetryId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Telemetry Routes
          GoRoute(
            path: 'telemetry',
            name: 'telemetry',
            redirect: (context, state) {
              final authState = ref.read(authProvider);
              if (!authState.isAuthenticated) {
                return '/login';
              }
              // Check if user has telemetry access (expert, admin, or moderator)
              final user = authState.user;
              if (user != null && !user.hasTelemetryAccess) {
                // Redirect to home if user doesn't have telemetry access
                return '/home';
              }
              return null; // Allow access
            },
            builder: (context, state) => const TelemetryFeature(),
            routes: [
              // Telemetry history route
              GoRoute(
                path: 'history',
                name: 'telemetry-history',
                builder: (context, state) => const TelemetryHistoryScreen(plantId: 'default_plant_id'),
              ),
              // Light measurement route
              GoRoute(
                path: 'light-measurement',
                name: 'light-measurement',
                builder: (context, state) => const LightMeasurementScreen(),
              ),
              // Growth photo capture route
              GoRoute(
                path: 'growth-photo-capture',
                name: 'growth-photo-capture',
                builder: (context, state) => const GrowthPhotoCaptureScreen(),
              ),
              // Telemetry detail route
              GoRoute(
                path: ':telemetryId',
                name: 'telemetry-detail',
                builder: (context, state) {
                  final telemetryId = state.pathParameters['telemetryId']!;
                  return TelemetryDetailScreen(telemetryId: telemetryId);
                },
              ),
            ],
          ),

          // Telemetry Demo Route (temporary for testing)
          GoRoute(
            path: 'telemetry-demo',
            name: 'telemetry-demo',
            builder: (context, state) => const TelemetryHistoryScreen(plantId: 'default_plant_id'),
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Route Names for easy access
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String camera = 'camera';
  static const String storyCreation = 'story-creation';
  static const String chat = 'chat';
  static const String conversation = 'conversation';
  static const String storyViewer = 'story-viewer';
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';
  static const String friends = 'friends';
  static const String addFriends = 'add-friends';
  static const String plants = 'plants';
  
  // Plant Care Routes
  static const String plantCare = 'plant-care';
  static const String addPlant = 'add-plant';
  static const String plantDetail = 'plant-detail';
  static const String careLogs = 'care-logs';
  static const String careReminders = 'care-reminders';
  
  // Plant Identification Routes
  static const String plantIdentification = 'plant-identification';
  static const String plantSearch = 'plant-search';
  static const String identificationHistory = 'identification-history';
  static const String plantSpeciesDetail = 'plant-species-detail';
  
  // Plant Community Routes
  static const String plantCommunity = 'plant-community';
  static const String plantQuestions = 'plant-questions';
  static const String plantTrades = 'plant-trades';
  static const String trendingTopics = 'trending-topics';
  
  // Care Plans Routes
  static const String carePlans = 'care-plans';
  static const String generateCarePlan = 'generate-care-plan';
  static const String carePlanDetail = 'care-plan-detail';
  
  // Telemetry Routes
  static const String plantTelemetry = 'plant-telemetry';
  static const String plantTelemetryDetail = 'plant-telemetry-detail';
  static const String telemetry = 'telemetry';
  static const String telemetryHistory = 'telemetry-history';
  static const String telemetryDetail = 'telemetry-detail';
  static const String lightMeasurement = 'light-measurement';
  static const String growthPhotoCapture = 'growth-photo-capture';
  static const String telemetryDemo = 'telemetry-demo';
}
