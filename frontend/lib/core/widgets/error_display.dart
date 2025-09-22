/// Error Display Widget
///
/// Provides customizable error display components for different error scenarios
/// throughout the application. Includes error messages, retry buttons, and
/// different error states for better user experience.
library;

import 'package:flutter/material.dart';

/// Basic error display widget
class ErrorDisplay extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;
  final String? retryText;
  final bool showIcon;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
    this.retryText,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                icon ?? Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
            ],
            if (title != null) ...[
              Text(
                title!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryText ?? 'Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error display
class NetworkErrorDisplay extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorDisplay({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      title: 'Connection Error',
      message: customMessage ?? 'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryText: 'Try Again',
    );
  }
}

/// Server error display
class ServerErrorDisplay extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const ServerErrorDisplay({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      title: 'Server Error',
      message: customMessage ?? 'Something went wrong on our end. Please try again later.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      retryText: 'Retry',
    );
  }
}

/// Not found error display
class NotFoundErrorDisplay extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onGoBack;

  const NotFoundErrorDisplay({
    super.key,
    this.customMessage,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      title: 'Not Found',
      message: customMessage ?? 'The item you\'re looking for could not be found.',
      icon: Icons.search_off,
      onRetry: onGoBack,
      retryText: 'Go Back',
    );
  }
}

/// Permission error display
class PermissionErrorDisplay extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRequestPermission;

  const PermissionErrorDisplay({
    super.key,
    this.customMessage,
    this.onRequestPermission,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorDisplay(
      title: 'Permission Required',
      message: customMessage ?? 'This feature requires additional permissions to work properly.',
      icon: Icons.lock_outline,
      onRetry: onRequestPermission,
      retryText: 'Grant Permission',
    );
  }
}

/// Inline error widget for forms
class InlineError extends StatelessWidget {
  final String message;
  final EdgeInsets padding;

  const InlineError({
    super.key,
    required this.message,
    this.padding = const EdgeInsets.only(top: 8.0),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error banner for temporary notifications
class ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionText;

  const ErrorBanner({
    super.key,
    required this.message,
    this.onDismiss,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.error,
            width: 4.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onAction != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onAction,
              child: Text(actionText ?? 'Action'),
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              iconSize: 20,
            ),
          ],
        ],
      ),
    );
  }
}