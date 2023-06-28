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
      this.strokeWidth = 1,
      super.center});

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
  void draw(Canvas canvas, Paint paint,Offset c, double animator) {
    if (c != center) {
      center = c;
    }
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
  Size get size => Size.square(outerRadius * 2);

  @override
  bool internal(Offset point) {
    double dis = point.distance2(center);
    return dis >= innerRadius && dis <= outerRadius;
  }
}
