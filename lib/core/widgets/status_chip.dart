import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Colored pill chip for status display (Safe, Warning, Danger).
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  /// Factory for attendance status.
  factory StatusChip.attendance(double percent, double threshold) {
    final statusColor = AppColors.attendanceStatus(percent, threshold);
    String label;
    IconData icon;
    if (statusColor == AppColors.success) {
      label = 'Safe';
      icon = Icons.check_circle_rounded;
    } else if (statusColor == AppColors.warning) {
      label = 'Warning';
      icon = Icons.warning_rounded;
    } else {
      label = 'Danger';
      icon = Icons.error_rounded;
    }
    return StatusChip(label: label, color: statusColor, icon: icon);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
