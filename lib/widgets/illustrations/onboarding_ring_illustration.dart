import 'dart:math';
import 'package:flutter/material.dart';

class OnboardingRingIllustration extends StatelessWidget {
  final double size;
  const OnboardingRingIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CustomPaint(
                size: Size(size, size),
                painter: _RingIllustrationPainter(
                  progress: value,
                  carbsColor: theme.colorScheme.primary,
                  proteinColor: theme.colorScheme.secondary,
                  fatColor: const Color(0xFFD47A22),
                  trackColor: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              );
            },
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1240',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              Text(
                'kcal left',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingIllustrationPainter extends CustomPainter {
  final double progress;
  final Color carbsColor;
  final Color proteinColor;
  final Color fatColor;
  final Color trackColor;

  _RingIllustrationPainter({
    required this.progress,
    required this.carbsColor,
    required this.proteinColor,
    required this.fatColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 10;
    const strokeWidth = 14.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw track background circle
    paint.color = trackColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      paint,
    );

    // Segment sweeps (270 degrees total)
    double currentStart = -pi / 2;
    const totalSweep = 1.5 * pi;

    final carbsSweep = totalSweep * 0.5 * progress;
    final proteinSweep = totalSweep * 0.3 * progress;
    final fatSweep = totalSweep * 0.2 * progress;

    if (carbsSweep > 0) {
      paint.color = carbsColor;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), currentStart, carbsSweep, false, paint);
      currentStart += carbsSweep;
    }

    if (proteinSweep > 0) {
      paint.color = proteinColor;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), currentStart, proteinSweep, false, paint);
      currentStart += proteinSweep;
    }

    if (fatSweep > 0) {
      paint.color = fatColor;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), currentStart, fatSweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RingIllustrationPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
