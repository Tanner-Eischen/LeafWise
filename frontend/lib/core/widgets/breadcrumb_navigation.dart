// Breadcrumb Navigation Widget
// Provides hierarchical navigation breadcrumbs for better user orientation

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Represents a single breadcrumb item
class BreadcrumbItem {
  final String label;
  final String? route;
  final IconData? icon;
  final bool isActive;

  const BreadcrumbItem({
    required this.label,
    this.route,
    this.icon,
    this.isActive = false,
  });
}

/// Breadcrumb navigation widget that displays hierarchical navigation
class BreadcrumbNavigation extends StatelessWidget {
  final List<BreadcrumbItem> items;
  final Color? activeColor;
  final Color? inactiveColor;
  final TextStyle? textStyle;
  final double spacing;
  final Widget? separator;

  const BreadcrumbNavigation({
    super.key,
    required this.items,
    this.activeColor,
    this.inactiveColor,
    this.textStyle,
    this.spacing = 8.0,
    this.separator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultActiveColor = activeColor ?? theme.primaryColor;
    final defaultInactiveColor = inactiveColor ?? theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6);
    final defaultSeparator = separator ?? Icon(
      Icons.chevron_right,
      size: 16,
      color: defaultInactiveColor,
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _buildBreadcrumbItems(
          context,
          defaultActiveColor,
          defaultInactiveColor,
          defaultSeparator,
        ),
      ),
    );
  }

  List<Widget> _buildBreadcrumbItems(
    BuildContext context,
    Color activeColor,
    Color? inactiveColor,
    Widget separator,
  ) {
    final List<Widget> widgets = [];

    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final isLast = i == items.length - 1;
      final isClickable = item.route != null && !item.isActive;

      // Add breadcrumb item
      widgets.add(
        _BreadcrumbItemWidget(
          item: item,
          isClickable: isClickable,
          activeColor: activeColor,
          inactiveColor: inactiveColor,
          textStyle: textStyle,
          onTap: isClickable ? () => context.go(item.route!) : null,
        ),
      );

      // Add separator if not last item
      if (!isLast) {
        widgets.add(SizedBox(width: spacing));
        widgets.add(separator);
        widgets.add(SizedBox(width: spacing));
      }
    }

    return widgets;
  }
}

/// Internal widget for individual breadcrumb items
class _BreadcrumbItemWidget extends StatelessWidget {
  final BreadcrumbItem item;
  final bool isClickable;
  final Color activeColor;
  final Color? inactiveColor;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const _BreadcrumbItemWidget({
    required this.item,
    required this.isClickable,
    required this.activeColor,
    this.inactiveColor,
    this.textStyle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = item.isActive ? activeColor : inactiveColor;
    final style = textStyle?.copyWith(color: color) ?? 
                  theme.textTheme.bodyMedium?.copyWith(color: color);

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
        ],
        Text(
          item.label,
          style: style,
        ),
      ],
    );

    if (isClickable) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Helper class to generate breadcrumbs from route paths
class BreadcrumbHelper {
  /// Generate breadcrumbs for telemetry routes
  static List<BreadcrumbItem> generateTelemetryBreadcrumbs(String currentRoute, {
    String? plantId,
    String? telemetryId,
    String? plantName,
  }) {
    final List<BreadcrumbItem> breadcrumbs = [];

    // Always start with Home
    breadcrumbs.add(const BreadcrumbItem(
      label: 'Home',
      route: '/home',
      icon: Icons.home,
    ));

    // Handle different telemetry route patterns
    if (currentRoute.contains('/plants/') && currentRoute.contains('/telemetry')) {
      // Plant-specific telemetry route: /home/plants/:plantId/telemetry
      breadcrumbs.add(const BreadcrumbItem(
        label: 'Plants',
        route: '/home/plants',
        icon: Icons.local_florist,
      ));

      if (plantId != null) {
        breadcrumbs.add(BreadcrumbItem(
          label: plantName ?? 'Plant $plantId',
          route: '/home/plants/$plantId',
          icon: Icons.eco,
        ));
      }

      if (currentRoute.endsWith('/telemetry')) {
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Telemetry',
          isActive: true,
          icon: Icons.sensors,
        ));
      } else if (telemetryId != null && plantId != null) {
        breadcrumbs.add( BreadcrumbItem(
          label: 'Telemetry',
          route: '/home/plants/$plantId/telemetry',
          icon: Icons.sensors,
        ));
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Details',
          isActive: true,
          icon: Icons.info,
        ));
      }
    } else if (currentRoute.startsWith('/home/telemetry')) {
      // General telemetry routes: /home/telemetry/*
      if (currentRoute == '/home/telemetry') {
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Telemetry',
          isActive: true,
          icon: Icons.sensors,
        ));
      } else if (currentRoute == '/home/telemetry/history') {
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Telemetry',
          route: '/home/telemetry',
          icon: Icons.sensors,
        ));
        breadcrumbs.add(const BreadcrumbItem(
          label: 'History',
          isActive: true,
          icon: Icons.history,
        ));
      } else if (currentRoute == '/home/telemetry/light-measurement') {
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Telemetry',
          route: '/home/telemetry',
          icon: Icons.sensors,
        ));
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Light Measurement',
          isActive: true,
          icon: Icons.light_mode,
        ));
      } else if (currentRoute == '/home/telemetry/growth-photo-capture') {
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Telemetry',
          route: '/home/telemetry',
          icon: Icons.sensors,
        ));
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Growth Photos',
          isActive: true,
          icon: Icons.photo_camera,
        ));
      } else if (telemetryId != null && currentRoute.contains(telemetryId)) {
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Telemetry',
          route: '/home/telemetry',
          icon: Icons.sensors,
        ));
        breadcrumbs.add(const BreadcrumbItem(
          label: 'Details',
          isActive: true,
          icon: Icons.info,
        ));
      }
    }

    return breadcrumbs;
  }

  /// Generate breadcrumbs from a route path
  static List<BreadcrumbItem> fromRoutePath(String routePath) {
    final segments = routePath.split('/').where((s) => s.isNotEmpty).toList();
    final List<BreadcrumbItem> breadcrumbs = [];

    String currentPath = '';
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      currentPath += '/$segment';
      final isLast = i == segments.length - 1;

      // Skip parameter segments (those starting with :)
      if (segment.startsWith(':')) continue;

      breadcrumbs.add(BreadcrumbItem(
        label: _formatSegmentLabel(segment),
        route: isLast ? null : currentPath,
        isActive: isLast,
      ));
    }

    return breadcrumbs;
  }

  /// Format segment label for display
  static String _formatSegmentLabel(String segment) {
    return segment
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}