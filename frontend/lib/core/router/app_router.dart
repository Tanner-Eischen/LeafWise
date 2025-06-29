import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:plant_social/features/auth/presentation/screens/login_screen.dart';
import 'package:plant_social/features/auth/presentation/screens/register_screen.dart';
import 'package:plant_social/features/auth/presentation/screens/splash_screen.dart';
import 'package:plant_social/features/home/presentation/screens/main_screen.dart';
<<<<<<< HEAD
import 'package:plant_social/features/camera/presentation/screens/camera_screen.dart';
import 'package:plant_social/features/chat/presentation/screens/chat_screen.dart';
import 'package:plant_social/features/chat/presentation/screens/conversation_screen.dart';
import 'package:plant_social/features/stories/presentation/screens/story_viewer_screen.dart';
import 'package:plant_social/features/stories/presentation/screens/story_creation_screen.dart';
import 'package:plant_social/features/profile/presentation/screens/profile_screen.dart';
import 'package:plant_social/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:plant_social/features/friends/presentation/screens/friends_screen.dart';
import 'package:plant_social/features/friends/presentation/screens/add_friends_screen.dart';
import 'package:plant_social/features/plant/presentation/screens/plant_features_screen.dart';
=======
>>>>>>> baf556a5d654e56b6d571fc759b0e5caa549cb96
import 'package:plant_social/features/auth/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  
  return GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/register';
      
      // If not logged in and not on auth screens, redirect to login
      if (!isLoggedIn && !isLoggingIn && state.matchedLocation != '/splash') {
        return '/login';
      }
      
      // If logged in and on auth screens, redirect to home
      if (isLoggedIn && isLoggingIn) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ),
      
      // Authentication Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (BuildContext context, GoRouterState state) => const RegisterScreen(),
      ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) => const MainScreen(),
<<<<<<< HEAD
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
                  return ConversationScreen(
                    userId: userId,
                    userName: userName,
                  );
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
              return StoryViewerScreen(
                storyId: storyId,
                userId: userId,
              );
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
          ),
        ],
=======
>>>>>>> baf556a5d654e56b6d571fc759b0e5caa549cb96
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
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
}