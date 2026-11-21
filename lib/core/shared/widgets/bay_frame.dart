import 'package:flutter/material.dart';

import '../../style/app_size.dart';

/// Four painted corner marks, like the ones that bound a parking bay.
///
/// The app's whole subject is a car handed over in a marked bay, so the
/// brackets carry that vocabulary instead of a generic rounded card. They
/// frame [child] without boxing it in.
class BayFrame extends StatelessWidget {
  const BayFrame({
    required this.child,
    required this.color,
    super.key,
    this.armLength = 36,
    this.strokeWidth = 3,
    this.padding = 28,
  });

  /// What sits inside the bay.
  final Widget child;

  /// Paint colour for the marks.
  final Color color;

  /// Length of each bracket arm, in design units.
  final double armLength;

  /// Thickness of the paint, in design units.
  final double strokeWidth;

  /// Space between the marks and [child], in design units.
  final double padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BayFramePainter(
        color: color,
        armLength: AppSize.getSize(armLength),
        strokeWidth: AppSize.getSize(strokeWidth),
      ),
      child: Padding(
        padding: AppSize.padding(all: padding),
        child: child,
      ),
    );
  }
}

class _BayFramePainter extends CustomPainter {
  const _BayFramePainter({
    required this.color,
    required this.armLength,
    required this.strokeWidth,
  });

  final Color color;
  final double armLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final double arm = armLength.clamp(0, size.shortestSide / 2);

    // Top-left
    canvas.drawLine(Offset.zero, Offset(arm, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, arm), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - arm, 0), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, arm), paint);
    // Bottom-left
    canvas.drawLine(Offset(0, size.height - arm), Offset(0, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(arm, size.height), paint);
    // Bottom-right
    canvas.drawLine(
      Offset(size.width, size.height - arm),
      Offset(size.width, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - arm, size.height),
      Offset(size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BayFramePainter old) =>
      old.color != color ||
      old.armLength != armLength ||
      old.strokeWidth != strokeWidth;
}
