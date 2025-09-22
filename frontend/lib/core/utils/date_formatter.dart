/// Date Formatter Utilities
///
/// Provides consistent date formatting functions throughout the application.
/// Includes relative time formatting, localized date strings, and various
/// date display formats for different use cases.
library;

import 'package:intl/intl.dart';

/// Date formatter utility class
class DateFormatter {
  // Private constructor to prevent instantiation
  DateFormatter._();

  /// Format date as relative time (e.g., "2 hours ago", "Yesterday")
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        final weeks = (difference.inDays / 7).floor();
        return weeks == 1 ? '1 week ago' : '$weeks weeks ago';
      }
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Format date as short date string (e.g., "Jan 15, 2024")
  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d, y').format(dateTime);
  }

  /// Format date as long date string (e.g., "January 15, 2024")
  static String formatLongDate(DateTime dateTime) {
    return DateFormat('MMMM d, y').format(dateTime);
  }

  /// Format date with time (e.g., "Jan 15, 2024 at 2:30 PM")
  static String formatDateWithTime(DateTime dateTime) {
    return DateFormat('MMM d, y \'at\' h:mm a').format(dateTime);
  }

  /// Format time only (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  /// Format date for display in lists (e.g., "Today", "Yesterday", "Jan 15")
  static String formatListDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateTime.year == now.year) {
      return DateFormat('MMM d').format(dateTime);
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }

  /// Format date for care reminders (e.g., "Due today", "Due in 3 days", "Overdue by 2 days")
  static String formatReminderDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = dueDateOnly.difference(today).inDays;

    if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference > 1) {
      return 'Due in $difference days';
    } else if (difference == -1) {
      return 'Overdue by 1 day';
    } else {
      return 'Overdue by ${-difference} days';
    }
  }

  /// Format duration between two dates (e.g., "2 weeks", "3 months")
  static String formatDuration(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate);

    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year' : '$years years';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month' : '$months months';
    } else if (difference.inDays >= 7) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? '1 week' : '$weeks weeks';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? '1 day' : '${difference.inDays} days';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour' : '${difference.inHours} hours';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute' : '${difference.inMinutes} minutes';
    } else {
      return 'Just now';
    }
  }

  /// Format date for ISO string (e.g., "2024-01-15T14:30:00.000Z")
  static String formatIsoString(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Parse ISO string to DateTime
  static DateTime parseIsoString(String isoString) {
    return DateTime.parse(isoString);
  }

  /// Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return dateOnly == today;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return dateOnly == yesterday;
  }

  /// Check if date is in the current week
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return dateTime.isAfter(startOfWeek) && dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Get days until date
  static int daysUntil(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(dateTime.year, dateTime.month, dateTime.day);
    return dateOnly.difference(today).inDays;
  }
}