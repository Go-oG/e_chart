import 'package:flutter/material.dart';
import 'package:e_chart/src/ext/paint_ext.dart';
import 'symbol.dart';

class CircleSymbol extends ChartSymbol {
  final num outerRadius;
  final num innerRadius;
  final Color innerColor;
  final Color outerColor;
  final bool fill;
  final double strokeWidth;

  const CircleSymbol({
    this.innerRadius = 0,
    this.outerRadius = 8,
    this.innerColor = Colors.blueAccent,
    this.outerColor = Colors.blueAccent,
    this.fill = true,
    this.strokeWidth = 1,
  });

  const CircleSymbol.normal({
    this.outerRadius = 8,
    Color color = Colors.blueAccent,
  })  : innerRadius = 0,
        innerColor = color,
        outerColor = color,
        fill = true,
        strokeWidth = 0;

  @override
  void draw(Canvas canvas, Paint paint, Offset center,double animator) {
    paint.reset();
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    if (!fill) {
      paint.strokeWidth = strokeWidth;
    }
    paint.color = outerColor;
    canvas.drawCircle(center, outerRadius.toDouble(), paint);
    double ir = innerRadius.toDouble();
    if (ir > 0) {
      paint.color = innerColor;
      canvas.drawCircle(center, ir, paint);
    }
  }
  @override
  Size get size => Size.square(outerRadius*2);
}
