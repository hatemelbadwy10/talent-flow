import 'package:flutter/material.dart';

import 'dart:math' as math;

import '../app/core/styles.dart';

class StepWidget extends StatefulWidget {
  final double value;
  final Color foregroundColor;
  final Color backgroundColor;

  const StepWidget({
    Key? key,
    required this.foregroundColor,
    required this.backgroundColor,
    this.value = 25,
  }) : super(key: key);

  @override
  StepWidgetState createState() {
    return StepWidgetState();
  }
}

class StepWidgetState extends State<StepWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController? _controller;

  late Animation<double> curve;
  late Tween<double>? valueTween;
  Tween<Color?>? backgroundColorTween;
  Tween<Color?>? foregroundColorTween;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    curve = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeIn,
    );
    valueTween = Tween<double>(
      begin: 0,
      end: widget.value,
    );
    _controller!.forward();
  }

  @override
  void didUpdateWidget(StepWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != oldWidget.value) {
      // Try to start with the previous tween's end value. This ensures that we
      // have a smooth transition from where the previous animation reached.
      double beginValue = valueTween?.evaluate(curve) ?? oldWidget.value;

      // Update the value tween.
      valueTween = Tween<double>(
        begin: beginValue,
        end: widget.value,
      );

      if (oldWidget.backgroundColor != widget.backgroundColor) {
        backgroundColorTween = ColorTween(
          begin: oldWidget.backgroundColor,
          end: widget.backgroundColor,
        );
      } else {
        backgroundColorTween = null;
      }

      if (oldWidget.foregroundColor != widget.foregroundColor) {
        foregroundColorTween = ColorTween(
          begin: oldWidget.foregroundColor,
          end: widget.foregroundColor,
        );
      } else {
        foregroundColorTween = null;
      }

      _controller!
        ..value = 0
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedBuilder(
        animation: curve,
        child: Container(),
        builder: (context, child) {
          final backgroundColor =
              backgroundColorTween?.evaluate(curve) ?? widget.backgroundColor;
          final foregroundColor =
              foregroundColorTween?.evaluate(curve) ?? widget.foregroundColor;

          return CustomPaint(
            foregroundPainter: CircleProgressBarPainter(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              percentage: widget.value,
            ),
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Styles.PRIMARY_COLOR,
                borderRadius: BorderRadius.circular(1000),
              ),
              child: const Icon(
                Icons.arrow_forward,
                size: 32,
                color: Styles.WHITE_COLOR,
              ),
            ),
          );
        },
      ),
    );
  }
}

// Draws the progress bar.
class CircleProgressBarPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color foregroundColor;

  CircleProgressBarPainter({
    this.backgroundColor,
    required this.foregroundColor,
    required this.percentage,
    double? strokeWidth,
  }) : strokeWidth = strokeWidth ?? 3;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final Size constrainedSize =
        size - Offset(strokeWidth, strokeWidth) as Size;
    final shortestSide =
        math.min(constrainedSize.width, constrainedSize.height);
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final radius = (shortestSide / 2);

    // Start at the top. 0 radians represents the right edge
    const double startAngle = -(2 * math.pi * 0.25);
    final double sweepAngle = (2 * math.pi * (percentage));

    // Don't draw the background if we don't have a background color
    if (backgroundColor != null) {
      final backgroundPaint = Paint()
        ..color = backgroundColor!
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, radius, backgroundPaint);
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    final oldPainter = (oldDelegate as CircleProgressBarPainter);
    return oldPainter.percentage != percentage ||
        oldPainter.backgroundColor != backgroundColor ||
        oldPainter.foregroundColor != foregroundColor ||
        oldPainter.strokeWidth != strokeWidth;
  }
}
