import 'dart:math';
import 'package:flutter/material.dart';

/// Circular progress indicator with percentage displayed in center.
class ProgressRing extends StatelessWidget {
  final double percent;
  final Color color;
  final double size;
  final double strokeWidth;
  final TextStyle? valueStyle;

  const ProgressRing({
    super.key,
    required this.percent,
    required this.color,
    this.size = 72,
    this.strokeWidth = 6,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          percent: percent.clamp(0, 100),
          color: color,
          trackColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          strokeWidth: strokeWidth,
        ),
        child: Center(
          child: Text(
            '${percent.toStringAsFixed(0)}%',
            style: valueStyle ??
                theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  _RingPainter({
    required this.percent,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    final sweepAngle = (percent / 100) * 2 * pi;
    canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.percent != percent || oldDelegate.color != color;
}
