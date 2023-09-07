import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class CircleSymbol extends ChartSymbol {
  num outerRadius;
  num innerRadius;
  Color innerColor;
  Color outerColor;
  bool fill;
  double strokeWidth;

  CircleSymbol(
      {this.innerRadius = 0,
      this.outerRadius = 8,
      this.innerColor = Colors.blueAccent,
      this.outerColor = Colors.blueAccent,
      this.fill = true,
      this.strokeWidth = 1});

  CircleSymbol.normal({
    this.outerRadius = 8,
    Color color = Colors.blueAccent,
    super.center,
  })  : innerRadius = 0,
        innerColor = color,
        outerColor = color,
        fill = true,
        strokeWidth = 0;

  @override
  Size get size => Size.square(outerRadius * 2);

  @override
  bool internal2(Offset center, Size size, Offset point) {
    double dis = point.distance2(center);
    return dis <= (size.longestSide / 2);
  }

  @override
  void draw2(Canvas canvas, Paint paint, Offset offset, Size size) {
    if (innerRadius <= 0) {
      innerRadius = 0;
      outerRadius = size.longestSide / 2;
    } else {
      double p = innerRadius / outerRadius;
      outerRadius = size.longestSide / 2;
      innerRadius = p * outerRadius;
    }
    center = offset;
    num or = outerRadius;
    num ir = innerRadius;
    paint.reset();
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    if (!fill) {
      paint.strokeWidth = strokeWidth;
    }
    paint.color = outerColor;
    canvas.drawCircle(center, or.toDouble(), paint);
    if (ir > 0) {
      paint.color = innerColor;
      canvas.drawCircle(center, ir.toDouble(), paint);
    }
  }
}
