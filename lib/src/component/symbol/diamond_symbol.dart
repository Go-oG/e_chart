import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///棱形
class DiamondSymbol extends ChartSymbol {
  num shortSide;
  num longSide;
  num rotate;
  AreaStyle? style;
  LineStyle? border;
  late Path path;

  DiamondSymbol({
    this.style,
    this.border,
    this.shortSide = 8,
    this.longSide = 8,
    this.rotate = 0,
  }) {
    if (style == null || border == null) {
      throw ChartError("Style 和border 不能同时为空");
    }
    path = Path();
    path.moveTo(0, -shortSide / 2);
    path.lineTo(longSide / 2, 0);
    path.lineTo(0, center.dy + shortSide / 2);
    path.lineTo(-longSide / 2, 0);
    path.close();
  }

  @override
  Size get size => Size(longSide.toDouble(), shortSide.toDouble());


  @override
  bool internal2(Offset center, Size size, Offset point) {
    double minSize = size.shortestSide / 2;
    double maxSize = size.longestSide/ 2;
    List<Offset> ol = [
      Offset(0, -minSize),
      Offset(maxSize, 0),
      Offset(0,minSize),
      Offset(-maxSize,0),
      Offset(0, -minSize),
    ];
    return point.translate(-center.dx, -center.dy).inPolygon(ol);
  }

  @override
  void draw2(Canvas canvas, Paint paint, Offset offset, Size size) {
    center = offset;
    if (size != this.size) {
      shortSide = size.shortestSide;
      longSide = size.longestSide;
      path = buildPath(shortSide, longSide);
    }
    paint.reset();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    style?.drawPath(canvas, paint, path);
    border?.drawPath(canvas, paint, path, drawDash: true, needSplit: false);
    canvas.restore();
  }

  Path buildPath(num shortSide, num longSide) {
    double minSize = shortSide / 2;
    double maxSize = longSide / 2;
    Path path = Path();
    path.moveTo(0, -minSize);
    path.lineTo(maxSize, 0);
    path.lineTo(0, minSize);
    path.lineTo(-maxSize, 0);
    path.close();
    return path;
  }
}
