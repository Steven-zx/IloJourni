import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PinMarker extends StatelessWidget {
  final int? number;
  final double size; // diameter of the circular head
  final Color fillColor;
  final Color borderColor;
  final Color textColor;
  final bool shadow;

  const PinMarker({
    super.key,
    this.number,
    this.size = 28,
    this.fillColor = AppTheme.navy,
    this.borderColor = Colors.white,
    this.textColor = Colors.white,
    this.shadow = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = size * 2; // ensures the tip is at the bottom
    return SizedBox(
      width: size,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, height),
            painter: _PinPainter(
              fillColor: fillColor,
              borderColor: borderColor,
              shadow: shadow,
            ),
          ),
          if (number != null)
            Align(
              alignment: const Alignment(0, -0.55),
              child: Text(
                number.toString(),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: size * 0.5 * 0.9,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  final Color fillColor;
  final Color borderColor;
  final bool shadow;

  _PinPainter({
    required this.fillColor,
    required this.borderColor,
    this.shadow = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final cx = size.width / 2;
    final cy = r + 2; // center of circular head
    final tipY = size.height - 1;

    final path = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx + r, cy - r, cx + r, cy)
      ..quadraticBezierTo(cx + r, cy + r, cx, tipY)
      ..quadraticBezierTo(cx - r, cy + r, cx - r, cy)
      ..quadraticBezierTo(cx - r, cy - r, cx, cy - r)
      ..close();

    if (shadow) {
      final shadowPaint = Paint()
        ..color = Colors.black26
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(path.shift(const Offset(0, 1)), shadowPaint);
    }

    final fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fill);

    final stroke = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.shadow != shadow;
  }
}
