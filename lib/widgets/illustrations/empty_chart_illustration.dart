import 'package:flutter/material.dart';

class EmptyChartIllustration extends StatelessWidget {
  final double size;
  const EmptyChartIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: Size(size, size * 0.7),
      painter: _ChartPainter(
        color: theme.colorScheme.outline,
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color color;

  _ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final dashPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final barOutlinePaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw X and Y axis lines
    final bottomY = size.height - 20;
    canvas.drawLine(Offset(10, bottomY), Offset(size.width - 10, bottomY), axisPaint);
    canvas.drawLine(const Offset(20, 10), Offset(20, bottomY), axisPaint);

    // Draw dashed target line
    final targetY = size.height * 0.35;
    double startX = 20;
    while (startX < size.width - 15) {
      canvas.drawLine(Offset(startX, targetY), Offset(startX + 6, targetY), dashPaint);
      startX += 12;
    }

    // Draw 7 empty bar outlines indicating empty logs
    const double padding = 12.0;
    final barWidth = (size.width - 40 - (6 * padding)) / 7;
    for (int i = 0; i < 7; i++) {
      final x = 30 + i * (barWidth + padding);
      // Empty outline bars at the bottom
      final r = Rect.fromLTWH(x, bottomY - 12, barWidth, 12);
      final rrect = RRect.fromRectAndCorners(
        r,
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      
      canvas.drawRRect(rrect, barOutlinePaint);
      
      // Draw a vertical dashed guide line up to the target
      double startY = bottomY - 12;
      while (startY > targetY + 5) {
        canvas.drawLine(Offset(x + barWidth / 2, startY), Offset(x + barWidth / 2, startY - 4), dashPaint);
        startY -= 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
