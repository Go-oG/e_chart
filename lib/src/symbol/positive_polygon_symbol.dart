import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///正多边形
class PositivePolygonSymbol extends ChartSymbol {
  LineStyle? border;
  AreaStyle? style;
  num r;
  int count;
  num rotate;
  late Path path;

  PositivePolygonSymbol({
    this.style,
    this.border,
    this.count = 3,
    this.r = 8,
    this.rotate = 0,
  }) {
    if (style == null && border == null) {
      throw ChartError("style 和border不能同时为空");
    }
    PositiveShape shape = PositiveShape(center: Offset.zero, r: r, count: count, angleOffset: rotate);
    path = shape.toPath(true);
  }

  @override
  Size get size => Size.square(r * 2);

  @override
  bool internal(Offset point) {
    return path.contains(point.translate(-center.dx, -center.dy));
  }

  @override
  void draw2(Canvas canvas, Paint paint, Offset offset, Size size) {
    center = offset;
    if (r != size.longestSide / 2) {
      r = size.longestSide / 2;
      var shape = PositiveShape(center: Offset.zero, r: r, count: count, angleOffset: rotate);
      path = shape.toPath(true);
    }
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    style?.drawPath(canvas, paint, path);
    border?.drawPath(canvas, paint, path, drawDash: true, needSplit: false);
    canvas.restore();
  }

  @override
  bool internal2(Offset center, Size size, Offset point) {
    var sp = PositiveShape(center: Offset.zero, r: r, count: count, angleOffset: rotate);
    return sp.toPath(true).contains(point.translate(-center.dx, -center.dy));
  }
}
