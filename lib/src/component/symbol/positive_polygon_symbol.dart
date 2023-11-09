import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///正多边形
class PositiveSymbol extends ChartSymbol {
  static final empty = PositiveSymbol(count: 0, r: 0);
  final num r;
  final int count;
  final num fixRotate;
  late final Path path;
  late final Rect bound = path.getBounds();

  PositiveSymbol({
    this.count = 3,
    this.r = 8,
    this.fixRotate = 0,
    super.borderStyle,
    super.itemStyle,
  }) {
    if (count <= 0 || r <= 0) {
      path = Path();
    } else {
      var shape = PositiveShape(center: Offset.zero, r: r, count: count, angleOffset: fixRotate);
      path = shape.toPath();
    }
  }

  @override
  Size get size => Size.square(r * 2);

  @override
  bool contains(Offset center, Offset point) {
    return path.contains(point.translate(-center.dx, -center.dy));
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (!checkStyle()) {
      return;
    }
    itemStyle.drawPath(canvas, paint, path, bound);
    borderStyle.drawPath(canvas, paint, path, drawDash: true,  bound: bound);
  }

  @override
  PositiveSymbol lerp(covariant PositiveSymbol end, double t) {
    var r = lerpDouble(this.r, end.r, t)!;
    var c = lerpInt(count, end.count, t);
    var ro = lerpDouble(fixRotate, end.fixRotate, t)!;
    return PositiveSymbol(
      fixRotate: ro,
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

    return PositiveSymbol(
      fixRotate: attr.rotate ?? fixRotate,
      r: r1,
      count: attr.borderCount ?? count,
      itemStyle: itemStyle,
      borderStyle: borderStyle,
    );
  }
}
