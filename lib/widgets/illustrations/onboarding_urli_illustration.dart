import 'package:flutter/material.dart';

class OnboardingUrliIllustration extends StatelessWidget {
  final double size;
  const OnboardingUrliIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: Size(size, size),
      painter: _UrliPainter(
        rimColor: theme.colorScheme.secondary,
        waterColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        outlineColor: theme.colorScheme.outline,
      ),
    );
  }
}

class _UrliPainter extends CustomPainter {
  final Color rimColor;
  final Color waterColor;
  final Color outlineColor;

  _UrliPainter({required this.rimColor, required this.waterColor, required this.outlineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final width = size.width - 24;
    final height = size.height - 40;

    final rimPaint = Paint()
      ..color = rimColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final thinStrokePaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final waterPaint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill;

    final petalPaint = Paint()
      ..color = rimColor
      ..style = PaintingStyle.fill;

    // Draw outer brass urli rim
    final outerRect = Rect.fromCenter(center: center, width: width, height: height);
    canvas.drawOval(outerRect, rimPaint);
    canvas.drawOval(outerRect, strokePaint);

    // Draw inner water basin
    final innerRect = Rect.fromCenter(center: center, width: width - 16, height: height - 16);
    canvas.drawOval(innerRect, waterPaint);
    canvas.drawOval(innerRect, strokePaint);

    // Side handles
    final leftHandle = Path()
      ..moveTo(center.dx - width / 2, center.dy - 12)
      ..quadraticBezierTo(center.dx - width / 2 - 12, center.dy, center.dx - width / 2, center.dy + 12);
    final rightHandle = Path()
      ..moveTo(center.dx + width / 2, center.dy - 12)
      ..quadraticBezierTo(center.dx + width / 2 + 12, center.dy, center.dx + width / 2, center.dy + 12);
    canvas.drawPath(leftHandle, strokePaint);
    canvas.drawPath(rightHandle, strokePaint);

    // Water ripple detail
    canvas.drawOval(Rect.fromCenter(center: center, width: width * 0.4, height: height * 0.4), thinStrokePaint);

    // Floating petals
    final List<Offset> petalPositions = [
      Offset(center.dx - 22, center.dy - 12),
      Offset(center.dx + 18, center.dy - 18),
      Offset(center.dx - 12, center.dy + 16),
      Offset(center.dx + 20, center.dy + 10),
    ];

    for (var pos in petalPositions) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      final petalPath = Path()
        ..moveTo(0, -6)
        ..quadraticBezierTo(-6, 0, 0, 6)
        ..quadraticBezierTo(6, 0, 0, -6)
        ..close();
      canvas.drawPath(petalPath, petalPaint);
      canvas.drawPath(petalPath, strokePaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
