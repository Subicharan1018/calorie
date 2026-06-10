import 'dart:math';
import 'package:flutter/material.dart';

class EmptyMeasuringTapeIllustration extends StatelessWidget {
  final double size;
  const EmptyMeasuringTapeIllustration({super.key, this.size = 200});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      size: Size(size, size),
      painter: _TapePainter(
        color: theme.colorScheme.outline,
      ),
    );
  }
}

class _TapePainter extends CustomPainter {
  final Color color;

  _TapePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final center = Offset(size.width / 2, size.height / 2);
    final path = Path();
    
    double startRadius = 15;
    double endRadius = size.width / 2 - 20;
    const double turns = 2.8;
    const int segments = 220;

    for (int i = 0; i <= segments; i++) {
      double t = (i / segments) * (turns * 2 * pi);
      double currentRadius = startRadius + (i / segments) * (endRadius - startRadius);
      double x = center.dx + currentRadius * cos(t);
      double y = center.dy + currentRadius * sin(t);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw ticks along the tape
      if (i > 40 && i % 3 == 0) {
        double normalX = cos(t);
        double normalY = sin(t);
        
        // Every 3rd tick is short, every 9th is medium, every 18th is long
        double tickLen = 4.0;
        if (i % 18 == 0) {
          tickLen = 9.0;
        } else if (i % 9 == 0) {
          tickLen = 6.5;
        }

        canvas.drawLine(
          Offset(x, y),
          Offset(x - normalX * tickLen, y - normalY * tickLen),
          tickPaint,
        );

        // Draw measurement numbers at long ticks
        if (i % 36 == 0 && i < segments - 20) {
          final String numStr = '${50 + (i ~/ 3.6).toInt()}';
          textPainter.text = TextSpan(
            text: numStr,
            style: TextStyle(color: color, fontSize: 9.0, fontWeight: FontWeight.bold),
          );
          textPainter.layout();
          
          canvas.save();
          // Position text slightly offset from ticks
          canvas.translate(x - normalX * 18, y - normalY * 18);
          canvas.rotate(t + pi/2);
          textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
          canvas.restore();
        }
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
