import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class RectSymbol extends ChartSymbol {
  final AreaStyle style;
  final Size rectSize;
  final num corner;

  const RectSymbol(
    this.style, {
    this.rectSize = const Size(16, 16),
    this.corner = 0,
  });

  @override
  void draw(Canvas canvas, Paint paint, Offset center,double animator) {
    style.drawRect(canvas, paint, Rect.fromCenter(center: center, width: rectSize.width, height: rectSize.height), corner.toDouble());
  }

  @override
  Size get size => rectSize;
}
