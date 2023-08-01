import 'dart:ui';
import 'package:e_chart/e_chart.dart';


///正多边形
class PositivePolygonSymbol extends ChartSymbol {
  final LineStyle? border;
  final AreaStyle? style;
  final num r;
  final int count;
  final num rotate;

  late final Path path;

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
    PositiveShape shape = PositiveShape(center: center, r: r, count: count, angleOffset: rotate);
    path = shape.toPath(true);
  }

  @override
  void draw(Canvas canvas, Paint paint, Offset offset) {
    center=offset;
    style?.drawPath(canvas, paint, path);
    border?.drawPath(canvas, paint, path,drawDash: true,needSplit: false);
  }

  @override
  Size get size => Size.square(r * 2);

  @override
  bool internal(Offset point) {
    return path.contains(point.translate(-center.dx,-center.dy));
  }
}
