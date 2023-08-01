import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///棱形
class DiamondSymbol extends ChartSymbol {
  final num shortSide;
  final num loneSide;
  final num rotate;
  final AreaStyle? style;
  final LineStyle? border;
  late final Path path;

  DiamondSymbol({
    this.style,
    this.border,
    this.shortSide = 8,
    this.loneSide = 8,
    this.rotate = 0,
  }) {
    if (style == null || border == null) {
      throw ChartError("Style 和border 不能同时为空");
    }
    path = Path();
    path.moveTo(0, -shortSide / 2);
    path.lineTo(loneSide / 2, 0);
    path.lineTo(0, center.dy + shortSide / 2);
    path.lineTo(-loneSide / 2, 0);
    path.close();
  }

  @override
  void draw(Canvas canvas, Paint paint, Offset offset) {
    center = offset;
    paint.reset();
    style?.drawPath(canvas, paint, path);
    border?.drawPath(canvas, paint, path, drawDash: true, needSplit: false);
  }

  @override
  Size get size => Size(loneSide.toDouble(), shortSide.toDouble());

  @override
  bool internal(Offset point) {
    return path.contains(point.translate(-center.dx, -center.dy));
  }
}
