import 'package:flutter/widgets.dart'
    show
        Animation,
        Canvas,
        Color,
        CustomPainter,
        Offset,
        Paint,
        PaintingStyle,
        Size,
        StrokeCap;
import 'dart:math' as math show pi;

class Custom20SecondTimer extends CustomPainter {
  final Color backgroundColor, color;
  final Animation<double> animation;

  Custom20SecondTimer(this.backgroundColor, this.color, this.animation)
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(Custom20SecondTimer old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
