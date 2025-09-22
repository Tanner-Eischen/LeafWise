class DateUtils {
  /// Formats a DateTime to a relative time string (e.g., "2 hours ago", "3 days ago")
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
      return difference.inDays == 1 ? '1 day ago' : '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  /// Formats a DateTime to a short date string (e.g., "Mar 15", "Dec 3, 2023")
  static String formatShortDate(DateTime dateTime) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;

    if (dateTime.year == now.year) {
      return '$month $day';
    } else {
      return '$month $day, ${dateTime.year}';
    }
  }

  /// Formats a DateTime to a full date string (e.g., "March 15, 2024")
  static String formatFullDate(DateTime dateTime) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;

    return '$month $day, $year';
  }

  /// Formats a DateTime to a time string (e.g., "2:30 PM", "14:30")
  static String formatTime(DateTime dateTime, {bool use24Hour = false}) {
    if (use24Hour) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else {
      final hour = dateTime.hour == 0
          ? 12
          : dateTime.hour > 12
              ? dateTime.hour - 12
              : dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = dateTime.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $period';
    }
  }

  /// Formats a DateTime to a date and time string (e.g., "Mar 15, 2:30 PM")
  static String formatDateTime(DateTime dateTime, {bool use24Hour = false}) {
    final date = formatShortDate(dateTime);
    final time = formatTime(dateTime, use24Hour: use24Hour);
    return '$date, $time';
  }

  /// Checks if a date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Checks if a date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Checks if a date is this week
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return dateTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Gets the start of the day for a given DateTime
  static DateTime startOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Gets the end of the day for a given DateTime
  static DateTime endOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }

  /// Calculates the number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = startOfDay(from);
    to = startOfDay(to);
    return to.difference(from).inDays;
  }

  /// Formats a duration to a human-readable string
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    } else {
      return '${duration.inSeconds}s';
    }
  }

  /// Parses an ISO 8601 string to DateTime
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }
    
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Formats a DateTime to ISO 8601 string
  static String toIso8601(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Gets a user-friendly format based on how recent the date is
  static String formatSmart(DateTime dateTime) {
    if (isToday(dateTime)) {
      return formatTime(dateTime);
    } else if (isYesterday(dateTime)) {
      return 'Yesterday';
    } else if (isThisWeek(dateTime)) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return formatShortDate(dateTime);
    }
  }

  /// Formats a date range
  static String formatDateRange(DateTime start, DateTime end) {
    if (startOfDay(start) == startOfDay(end)) {
      // Same day
      return '${formatShortDate(start)}, ${formatTime(start)} - ${formatTime(end)}';
    } else if (start.year == end.year) {
      // Same year
      return '${formatShortDate(start)} - ${formatShortDate(end)}';
    } else {
      // Different years
      return '${formatShortDate(start)}, ${start.year} - ${formatShortDate(end)}, ${end.year}';
    }
  }
}