import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_social/core/theme/app_theme.dart';
import 'package:plant_social/core/router/app_router.dart';
import 'package:plant_social/core/constants/app_constants.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PlantSocialApp(),
    ),
  );
}

class PlantSocialApp extends ConsumerWidget {
  const PlantSocialApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}