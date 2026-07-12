import 'package:flutter/material.dart';

/// Custom floating snackbar with icon, rounded corners, and animation.
class AppSnackBar {
  AppSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? iconColor,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor ?? Colors.white, size: 20),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: theme.colorScheme.primary,
                onPressed: onAction ?? () {},
              )
            : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  /// Show a success snackbar.
  static void success(BuildContext context, String message) {
    show(context,
        message: message,
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF22C55E));
  }

  /// Show an error snackbar.
  static void error(BuildContext context, String message) {
    show(context,
        message: message,
        icon: Icons.error_rounded,
        iconColor: const Color(0xFFEF4444));
  }
}
