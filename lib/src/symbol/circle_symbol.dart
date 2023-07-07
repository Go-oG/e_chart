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
  void draw(Canvas canvas, Paint paint, SymbolDesc info) {
    if (info.center != null && center != info.center) {
      center = info.center!;
    }
    num or = info.size?.longestSide ?? outerRadius;
    num ir;
    if (innerRadius <= 0) {
      ir = 0;
    } else {
      ir = info.size == null ? innerRadius : (info.size!.longestSide - (outerRadius - innerRadius));
    }

    paint.reset();
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    if (!fill) {
      paint.strokeWidth = strokeWidth;
    }
    paint.color = info.fillColor.isEmpty ? outerColor : info.fillColor.first;
    canvas.drawCircle(center, or.toDouble(), paint);
    if (ir > 0) {
      paint.color = info.fillColor.length >= 2 ? info.fillColor[1] : innerColor;
      canvas.drawCircle(center, ir.toDouble(), paint);
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
