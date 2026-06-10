import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kalori/core/models/daily_summary.dart';
import 'package:kalori/l10n/app_strings.dart';

class DeficitRingWidget extends StatefulWidget {
  final DailySummary summary;
  const DeficitRingWidget({super.key, required this.summary});

  @override
  State<DeficitRingWidget> createState() => _DeficitRingWidgetState();
}

class _DeficitRingWidgetState extends State<DeficitRingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DeficitRingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.summary.consumedKcal != widget.summary.consumedKcal) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = AppStrings.of(context);
    
    return AspectRatio(
      aspectRatio: 1.2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                size: const Size.square(240),
                painter: _RingPainter(
                  summary: widget.summary,
                  progress: _animation.value,
                  carbsColor: theme.colorScheme.primary,
                  proteinColor: theme.colorScheme.secondary,
                  fatColor: const Color(0xFFD47A22), // Warm terracotta/rust for fat to avoid gold/green collision
                  trackColor: theme.colorScheme.outline.withValues(alpha: 0.1),
                ),
              );
            },
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final animatedValue = (widget.summary.consumedKcal * _animation.value).toInt();
              final animatedRemaining = widget.summary.targetKcal - animatedValue;
              final displayVal = animatedRemaining > 0 ? animatedRemaining : 0;
              final isOver = animatedRemaining < 0;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOver ? '${-animatedRemaining}' : '$displayVal',
                    style: theme.textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isOver ? theme.colorScheme.error : theme.colorScheme.primary,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isOver
                        ? (s.isTamil ? 'அதிகப்படியானது' : 'over target')
                        : (s.isTamil ? 'மீதமுள்ளது' : 'remaining'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final DailySummary summary;
  final double progress;
  final Color carbsColor;
  final Color proteinColor;
  final Color fatColor;
  final Color trackColor;

  _RingPainter({
    required this.summary,
    required this.progress,
    required this.carbsColor,
    required this.proteinColor,
    required this.fatColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 16;
    const strokeWidth = 24.0;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw track
    paint.color = trackColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      paint,
    );

    if (summary.consumedKcal == 0) return;

    final double totalCap = max(summary.consumedKcal.toDouble(), summary.targetKcal.toDouble());
    
    final double carbsKcal = summary.consumedCarbs * 4;
    final double proteinKcal = summary.consumedProtein * 4;
    final double fatKcal = summary.consumedFat * 9;
    
    final double carbsAngle = (carbsKcal / totalCap) * 2 * pi * progress;
    final double proteinAngle = (proteinKcal / totalCap) * 2 * pi * progress;
    final double fatAngle = (fatKcal / totalCap) * 2 * pi * progress;

    double currentStart = -pi / 2;

    if (carbsAngle > 0) {
      paint.color = carbsColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentStart,
        carbsAngle,
        false,
        paint,
      );
      currentStart += carbsAngle;
    }

    if (proteinAngle > 0) {
      paint.color = proteinColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentStart,
        proteinAngle,
        false,
        paint,
      );
      currentStart += proteinAngle;
    }

    if (fatAngle > 0) {
      paint.color = fatColor;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentStart,
        fatAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.summary != summary;
  }
}
