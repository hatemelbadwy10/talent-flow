import 'package:flutter/material.dart';

import '../app/core/styles.dart';

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Styles.BORDER_COLOR
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double dashWidth = 8, dashSpace = 5, startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DashedLine extends StatelessWidget {
  const DashedLine({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, 2), // Full-width horizontal line
      painter: DashedLinePainter(),
    );
  }
}
