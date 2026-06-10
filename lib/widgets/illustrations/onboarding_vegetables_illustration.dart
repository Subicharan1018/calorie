import 'dart:math';
import 'package:flutter/material.dart';

class OnboardingVegetablesIllustration extends StatelessWidget {
  final double size;
  const OnboardingVegetablesIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: Size(size, size),
      painter: _VegetablesPainter(
        color: theme.colorScheme.primary,
        outlineColor: theme.colorScheme.outline,
      ),
    );
  }
}

class _VegetablesPainter extends CustomPainter {
  final Color color;
  final Color outlineColor;

  _VegetablesPainter({required this.color, required this.outlineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final cellWidth = size.width / 2;
    final cellHeight = size.height / 2;

    // Cell 1: Drumstick (diagonal long curved shape)
    canvas.save();
    canvas.translate(cellWidth * 0.5, cellHeight * 0.5);
    canvas.rotate(-pi / 6);
    final drumstickPath = Path()
      ..moveTo(-8, -45)
      ..quadraticBezierTo(0, 0, 8, 45)
      ..lineTo(3, 45)
      ..quadraticBezierTo(-5, 0, -13, -45)
      ..close();
    canvas.drawPath(drumstickPath, fillPaint);
    canvas.drawPath(drumstickPath, strokePaint);
    // Draw ridges on drumstick
    canvas.drawLine(const Offset(-4, -20), const Offset(4, 20), strokePaint);
    canvas.restore();

    // Cell 2: Banana Flower (teardrop/pointed pod)
    canvas.save();
    canvas.translate(cellWidth * 1.5, cellHeight * 0.5);
    canvas.rotate(pi / 12);
    final flowerPath = Path()
      ..moveTo(0, -40)
      ..cubicTo(-25, -5, -20, 25, 0, 40)
      ..cubicTo(20, 25, 25, -5, 0, -40)
      ..close();
    canvas.drawPath(flowerPath, fillPaint);
    canvas.drawPath(flowerPath, strokePaint);
    
    // Petal overlay line
    final leafLine = Path()
      ..moveTo(0, -40)
      ..quadraticBezierTo(-8, 5, 0, 40);
    canvas.drawPath(leafLine, strokePaint);
    canvas.restore();

    // Cell 3: Ash Gourd (large smooth oval)
    canvas.save();
    canvas.translate(cellWidth * 0.5, cellHeight * 1.5);
    canvas.rotate(pi / 8);
    final rect = Rect.fromCenter(center: Offset.zero, width: 45, height: 70);
    canvas.drawOval(rect, fillPaint);
    canvas.drawOval(rect, strokePaint);
    
    // Ash gourd vertical ridges
    canvas.drawLine(const Offset(0, -35), const Offset(0, 35), strokePaint);
    canvas.restore();

    // Cell 4: Brinjal (eggplant)
    canvas.save();
    canvas.translate(cellWidth * 1.5, cellHeight * 1.5);
    canvas.rotate(-pi / 12);
    final brinjalPath = Path()
      ..moveTo(0, -32) // Stem base
      ..lineTo(-6, -20)
      ..cubicTo(-25, -10, -25, 20, 0, 32) // Bulbous bottom
      ..cubicTo(25, 20, 25, -10, 6, -20)
      ..close();
    canvas.drawPath(brinjalPath, fillPaint);
    canvas.drawPath(brinjalPath, strokePaint);
    
    // Stem crown details
    final crownPath = Path()
      ..moveTo(-6, -20)
      ..lineTo(0, -30)
      ..lineTo(6, -20)
      ..moveTo(0, -30)
      ..lineTo(0, -20);
    canvas.drawPath(crownPath, strokePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
