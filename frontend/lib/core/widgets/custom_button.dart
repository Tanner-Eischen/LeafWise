/// Reusable custom button widgets for consistent styling across the app
/// Provides various button styles with loading states and customization options
library;

import 'package:flutter/material.dart';
import 'loading_widget.dart';

/// Primary custom button with loading state support
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !isEnabled || isLoading || onPressed == null;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.primaryColor,
          foregroundColor: textColor ?? Colors.white,
          disabledBackgroundColor: theme.disabledColor,
          disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(
            0.38,
          ),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          elevation: isDisabled ? 0 : 2,
        ),
        child: isLoading
            ? const SmallLoadingWidget(color: Colors.white)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Secondary/outline button variant
class CustomOutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const CustomOutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.borderColor,
    this.textColor,
    this.width,
    this.height = 48,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !isEnabled || isLoading || onPressed == null;
    final effectiveBorderColor = borderColor ?? theme.primaryColor;
    final effectiveTextColor = textColor ?? theme.primaryColor;

    return SizedBox(
      width: width,
      height: height,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveTextColor,
          disabledForegroundColor: theme.disabledColor,
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: BorderSide(
            color: isDisabled ? theme.disabledColor : effectiveBorderColor,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? SmallLoadingWidget(color: effectiveTextColor)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: effectiveTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Text button variant
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Color? textColor;
  final EdgeInsets? padding;

  const CustomTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.textColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = !isEnabled || isLoading || onPressed == null;
    final effectiveTextColor = textColor ?? theme.primaryColor;

    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: effectiveTextColor,
        disabledForegroundColor: theme.disabledColor,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: isLoading
          ? SmallLoadingWidget(color: effectiveTextColor)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: effectiveTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

/// Floating action button variant
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const CustomFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: isLoading ? null : onPressed,
      backgroundColor: backgroundColor ?? theme.primaryColor,
      child: isLoading
          ? const SmallLoadingWidget(color: Colors.white)
          : Icon(icon, color: iconColor ?? Colors.white, size: size ?? 24),
    );
  }
}
