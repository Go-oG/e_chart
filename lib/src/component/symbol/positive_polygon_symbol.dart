import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///正多边形
class PositiveSymbol extends ChartSymbol {
  static final empty = PositiveSymbol(count: 0, r: 0);
  final num r;
  final int count;
  final num rotate;
  late final Path path;

  PositiveSymbol({
    this.count = 3,
    this.r = 8,
    this.rotate = 0,
    super.borderStyle,
    super.itemStyle,
  }) {
    if (count <= 0 || r <= 0) {
      path = Path();
    } else {
      PositiveShape shape = PositiveShape(center: Offset.zero, r: r, count: count, angleOffset: rotate);
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
  void onDraw(Canvas canvas, Paint paint) {
    if (!checkStyle()) {
      return;
    }
    itemStyle.drawPath(canvas, paint, path);
    borderStyle.drawPath(canvas, paint, path, drawDash: true, needSplit: false);

    // num r = attr.shape.r;
    // double scale = 1 - (lineStyle.width / (2 * r));
    // Matrix4 m4 = Matrix4.identity();
    // m4.translate(attr.center.dx, attr.center.dy);
    // m4.scale(scale, scale);
    // m4.translate(-attr.center.dx, -attr.center.dy);
    // var path2 = path.transform(m4.storage);
    // lineStyle.drawPath(canvas, paint, path2, drawDash: true, needSplit: false);
  }

  @override
  PositiveSymbol lerp(covariant PositiveSymbol end, double t) {
    var r = lerpDouble(this.r, end.r, t)!;
    var c = lerpInt(count, end.count, t);
    var ro = lerpDouble(rotate, end.rotate, t)!;
    return PositiveSymbol(
      rotate: ro,
      r: r,
      count: c,
      itemStyle: AreaStyle.lerp(itemStyle, end.itemStyle, t) ?? AreaStyle.empty,
      borderStyle: LineStyle.lerp(borderStyle, end.borderStyle, t) ?? LineStyle.empty,
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
      rotate: attr.rotate ?? rotate,
      r: r1,
      count: attr.borderCount ?? count,
      itemStyle: itemStyle,
      borderStyle: borderStyle,
    );
  }
}
