/// Color Utilities
///
/// Provides color manipulation functions, theme-related utilities, and
/// consistent color schemes throughout the application. Includes functions
/// for color generation, contrast calculation, and accessibility helpers.
library;

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Color utility class
class ColorUtils {
  // Private constructor to prevent instantiation
  ColorUtils._();

  /// Generate a color from a string (useful for user avatars, plant categories, etc.)
  static Color colorFromString(String input) {
    final hash = input.hashCode;
    final hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.7, 0.8).toColor();
  }

  /// Get contrasting text color (black or white) for a given background color
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Calculate the contrast ratio between two colors
  static double calculateContrastRatio(Color color1, Color color2) {
    final luminance1 = color1.computeLuminance();
    final luminance2 = color2.computeLuminance();
    final lighter = math.max(luminance1, luminance2);
    final darker = math.min(luminance1, luminance2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Check if two colors have sufficient contrast for accessibility (WCAG AA)
  static bool hasGoodContrast(Color color1, Color color2) {
    return calculateContrastRatio(color1, color2) >= 4.5;
  }

  /// Lighten a color by a given amount (0.0 to 1.0)
  static Color lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = math.min(1.0, hsl.lightness + amount);
    return hsl.withLightness(lightness).toColor();
  }

  /// Darken a color by a given amount (0.0 to 1.0)
  static Color darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = math.max(0.0, hsl.lightness - amount);
    return hsl.withLightness(lightness).toColor();
  }

  /// Adjust the opacity of a color
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(math.max(0.0, math.min(1.0, opacity)));
  }

  /// Get a complementary color
  static Color getComplementaryColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final complementaryHue = (hsl.hue + 180) % 360;
    return hsl.withHue(complementaryHue).toColor();
  }

  /// Get an analogous color (adjacent on color wheel)
  static Color getAnalogousColor(Color color, {double offset = 30}) {
    final hsl = HSLColor.fromColor(color);
    final analogousHue = (hsl.hue + offset) % 360;
    return hsl.withHue(analogousHue).toColor();
  }

  /// Get a triadic color (120 degrees apart on color wheel)
  static Color getTriadicColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    final triadicHue = (hsl.hue + 120) % 360;
    return hsl.withHue(triadicHue).toColor();
  }

  /// Convert hex string to Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert Color to hex string
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  /// Plant health status colors
  static Color getHealthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'excellent':
        return const Color(0xFF4CAF50); // Green
      case 'good':
        return const Color(0xFF8BC34A); // Light Green
      case 'fair':
        return const Color(0xFFFFEB3B); // Yellow
      case 'poor':
        return const Color(0xFFFF9800); // Orange
      case 'critical':
        return const Color(0xFFF44336); // Red
      default:
        return Colors.grey;
    }
  }

  /// Care type colors
  static Color getCareTypeColor(String careType) {
    switch (careType.toLowerCase()) {
      case 'watering':
        return const Color(0xFF2196F3); // Blue
      case 'fertilizing':
        return const Color(0xFF4CAF50); // Green
      case 'pruning':
        return const Color(0xFF795548); // Brown
      case 'repotting':
        return const Color(0xFF9C27B0); // Purple
      case 'pest_control':
        return const Color(0xFFFF5722); // Deep Orange
      case 'disease_treatment':
        return const Color(0xFFE91E63); // Pink
      default:
        return Colors.grey;
    }
  }

  /// Priority colors
  static Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFF44336); // Red
      case 'medium':
        return const Color(0xFFFF9800); // Orange
      case 'low':
        return const Color(0xFF4CAF50); // Green
      default:
        return Colors.grey;
    }
  }

  /// Generate a gradient from a base color
  static LinearGradient generateGradient(Color baseColor, {bool vertical = true}) {
    final lightColor = lighten(baseColor, 0.2);
    final darkColor = darken(baseColor, 0.2);
    
    return LinearGradient(
      begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
      end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
      colors: [lightColor, baseColor, darkColor],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  /// Create a material color swatch from a single color
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (final strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(color.value, swatch);
  }

  /// Get semantic colors for different states
  static Color getSemanticColor(String semantic) {
    switch (semantic.toLowerCase()) {
      case 'success':
        return const Color(0xFF4CAF50);
      case 'warning':
        return const Color(0xFFFF9800);
      case 'error':
        return const Color(0xFFF44336);
      case 'info':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  /// Check if a color is considered "dark"
  static bool isDark(Color color) {
    return color.computeLuminance() < 0.5;
  }

  /// Check if a color is considered "light"
  static bool isLight(Color color) {
    return color.computeLuminance() >= 0.5;
  }
}