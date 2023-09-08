import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///正多边形
class PositivePolygonSymbol extends ChartSymbol {
  final num r;
  final int count;
  final num rotate;
  late final Path path;

  PositivePolygonSymbol({
    this.count = 3,
    this.r = 8,
    this.rotate = 0,
    super.borderStyle,
    super.itemStyle,
  }) {
    PositiveShape shape = PositiveShape(center: Offset.zero, r: r, count: count, angleOffset: rotate);
    path = shape.toPath();
  }

  @override
  Size get size => Size.square(r * 2);

  @override
  bool contains(Offset center, Offset point) {
    return path.contains(point.translate(-center.dx, -center.dy));
  }

  @override
  void draw(Canvas canvas, Paint paint, Offset offset) {
    if (!checkStyle()) {
      return;
    }
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    itemStyle?.drawPath(canvas, paint, path);
    borderStyle?.drawPath(canvas, paint, path, drawDash: true, needSplit: false);
    canvas.restore();
  }

  @override
  PositivePolygonSymbol lerp(covariant PositivePolygonSymbol end, double t) {
    var r = lerpDouble(this.r, end.r, t)!;
    var c = lerpInt(count, end.count, t);
    var ro = lerpDouble(rotate, end.rotate, t)!;
    return PositivePolygonSymbol(
      rotate: ro,
      r: r,
      count: c,
      itemStyle: AreaStyle.lerp(itemStyle, end.itemStyle, t),
      borderStyle: LineStyle.lerp(borderStyle, end.borderStyle, t),
    );
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    if (attr == null || attr.isEmpty) {
      return this;
    }
    var size = attr.size;
    var r1 = r;
    if (size != null) {
      r1 = size.shortestSide;
      if (r1 <= 0) {
        r1 = size.longestSide;
      }
      if (r1 <= 0) {
        r1 = r;
      } else {
        r1 *= 0.5;
      }
    }

    return PositivePolygonSymbol(
      rotate: attr.rotate ?? rotate,
      r: r1,
      count: attr.borderCount ?? count,
      itemStyle: itemStyle,
      borderStyle: borderStyle,
    );
  }
}
