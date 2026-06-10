import 'dart:math';
import 'package:flutter/material.dart';

class EmptyThaliIllustration extends StatelessWidget {
  final double size;
  const EmptyThaliIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: Size(size, size),
      painter: _ThaliPainter(
        strokeColor: theme.colorScheme.outline,
        fillColor: theme.colorScheme.surfaceContainer.withValues(alpha: 0.5),
      ),
    );
  }
}

class _ThaliPainter extends CustomPainter {
  final Color strokeColor;
  final Color fillColor;

  _ThaliPainter({required this.strokeColor, required this.fillColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Draw thali fill
    canvas.drawCircle(center, radius, fillPaint);

    // Draw thali outer rim (double stroke)
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius - 4, paint);

    // Draw 5 katoris around the upper/outer rim
    final katoriRadius = radius * 0.22;
    for (int i = 0; i < 5; i++) {
      final angle = -pi + (i * pi / 4); // Arrange in arc from left to right
      final katoriCenter = Offset(
        center.dx + (radius - katoriRadius - 10) * cos(angle),
        center.dy + (radius - katoriRadius - 10) * sin(angle),
      );
      canvas.drawCircle(katoriCenter, katoriRadius, paint);
      canvas.drawCircle(katoriCenter, katoriRadius - 3, paint);
    }

    // Draw central rice mound outline
    final riceCenter = Offset(center.dx, center.dy + 15);
    final path = Path()
      ..moveTo(riceCenter.dx - 35, riceCenter.dy)
      ..quadraticBezierTo(riceCenter.dx, riceCenter.dy - 45, riceCenter.dx + 35, riceCenter.dy)
      ..quadraticBezierTo(riceCenter.dx, riceCenter.dy + 5, riceCenter.dx - 35, riceCenter.dy)
      ..close();
    canvas.drawPath(path, paint);

    // Inner detail inside rice mound
    final riceDetail = Path()
      ..moveTo(riceCenter.dx - 20, riceCenter.dy - 5)
      ..quadraticBezierTo(riceCenter.dx, riceCenter.dy - 25, riceCenter.dx + 20, riceCenter.dy - 5);
    canvas.drawPath(riceDetail, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
