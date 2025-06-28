import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? padding;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 56,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor = backgroundColor ??
        (isSecondary ? theme.colorScheme.surface : theme.colorScheme.primary);

    final effectiveTextColor = textColor ??
        (isSecondary ? theme.colorScheme.primary : theme.colorScheme.onPrimary);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: effectiveBackgroundColor.withOpacity(0.6),
          disabledForegroundColor: effectiveTextColor.withOpacity(0.6),
          elevation: isSecondary ? 0 : 2,
          shadowColor: theme.colorScheme.shadow.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSecondary
                ? BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.3),
                    width: 1,
                  )
                : BorderSide.none,
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    effectiveTextColor,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: effectiveTextColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: effectiveTextColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AuthIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;
  final bool isLoading;

  const AuthIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveBackgroundColor =
        backgroundColor ?? theme.colorScheme.surface;

    final effectiveIconColor = iconColor ?? theme.colorScheme.onSurface;

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: isLoading
                ? Center(
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveIconColor,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }
}
