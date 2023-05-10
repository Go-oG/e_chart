import 'package:e_chart/src/ext/paint_ext.dart';

import 'symbol.dart';
import 'package:flutter/material.dart';

class RectSymbol extends Symbol {
  final Color color;
  final bool fill;
  final double strokeWidth;
  final double radius;

  const RectSymbol({
    this.color = Colors.blue,
    this.fill = true,
    this.strokeWidth = 0,
    this.radius = 0,
  });

  @override
  void draw(Canvas canvas, Paint paint, Offset offset, Size size) {
    paint.reset();
    paint.color = color;
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    paint.strokeWidth = strokeWidth;

    if (radius > 0) {
      canvas.drawRRect(
          RRect.fromLTRBR(
            offset.dx - size.width / 2,
            offset.dy - size.height / 2,
            offset.dx + size.width / 2,
            offset.dy + size.height / 2,
            Radius.circular(radius),
          ),
          paint);
    } else {
      canvas.drawRect(Rect.fromCenter(center: offset, width: size.width, height: size.height), paint);
    }
  }
}
