import 'package:flutter/material.dart';

class EmptyKolamIllustration extends StatelessWidget {
  final double size;
  const EmptyKolamIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: Size(size, size),
      painter: _KolamPainter(
        color: theme.colorScheme.outline,
      ),
    );
  }
}

class _KolamPainter extends CustomPainter {
  final Color color;

  _KolamPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double step = size.width / 6;

    // Create 5x5 grid dots
    for (int r = 1; r <= 5; r++) {
      for (int c = 1; c <= 5; c++) {
        final dot = Offset(c * step, r * step);
        canvas.drawCircle(dot, 3.0, dotPaint);
      }
    }

    // Draw traditional loop designs wrapping around the grid dots
    final path = Path();
    
    // Outer boundary loops
    path.moveTo(step, 3 * step);
    path.cubicTo(0.5 * step, 2 * step, 2 * step, 0.5 * step, 3 * step, step);
    path.cubicTo(4 * step, 0.5 * step, 5.5 * step, 2 * step, 5 * step, 3 * step);
    path.cubicTo(5.5 * step, 4 * step, 4 * step, 5.5 * step, 3 * step, 5 * step);
    path.cubicTo(2 * step, 5.5 * step, 0.5 * step, 4 * step, step, 3 * step);
    path.close();

    // Cross-connecting center loops
    final path2 = Path()
      ..moveTo(2 * step, 3 * step)
      ..quadraticBezierTo(3 * step, 2 * step, 4 * step, 3 * step)
      ..quadraticBezierTo(3 * step, 4 * step, 2 * step, 3 * step)
      ..moveTo(3 * step, 2 * step)
      ..quadraticBezierTo(4 * step, 3 * step, 3 * step, 4 * step)
      ..quadraticBezierTo(2 * step, 3 * step, 3 * step, 2 * step);

    canvas.drawPath(path, linePaint);
    canvas.drawPath(path2, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
