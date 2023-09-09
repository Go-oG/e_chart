import 'dart:math';
import 'dart:ui';
import 'package:e_chart/e_chart.dart';

///类似地图当前位置的形状
///TODO 后面优化(当前不可用)
class PinSymbol extends ChartSymbol {
  final double r;
  final num rotate;
  late final Path path;

  PinSymbol({
    this.r = 8,
    this.rotate = 0,
    super.borderStyle,
    super.itemStyle,
  }) {
    path = buildPath(r);
  }

  @override
  Size get size => Size(r * 2, r * 2.5);

  @override
  void onDraw(Canvas canvas, Paint paint) {
    if (!checkStyle()) {
      return;
    }
    canvas.save();
    canvas.rotate(rotate * pi / 180);
    itemStyle.drawPath(canvas, paint, path);
    borderStyle.drawPath(canvas, paint, path, needSplit: false, drawDash: true);
    canvas.restore();
  }

  Path buildPath(double r) {
    Path p1 = Path();
    p1.moveTo(-r, 0);
    p1.arcToPoint(Offset(r, 0), radius: Radius.circular(r), largeArc: true);
    p1.arcToPoint(Offset(-r, 0), radius: Radius.circular(r), largeArc: true);
    p1.close();
    Path p2 = Path();
    p2.moveTo(r, 0);
    Offset bottom = Offset(0, r * 1.2);
    p2.quadraticBezierTo(r * 0.15, r * 0.77, bottom.dx, bottom.dy);
    p2.quadraticBezierTo(-r * 0.15, r * 0.77, -r, 0);
    p2.close();
    p1.addPath(p2, Offset.zero);
    return p1;
  }

  @override
  bool contains(Offset center, Offset point) {
    return path.contains(point.translate(center.dx, center.dy));
  }

  @override
  ChartSymbol lerp(covariant PinSymbol end, double t) {
    var r1 = lerpDouble(r, end.r, t)!;
    var rotate = lerpDouble(this.rotate, end.rotate, t)!;
    return PinSymbol(
      r: r1,
      rotate: rotate,
      itemStyle: AreaStyle.lerp(itemStyle, end.itemStyle, t)??AreaStyle.empty,
      borderStyle: LineStyle.lerp(borderStyle, end.borderStyle, t)??LineStyle.empty,
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
    var rotate = attr.rotate ?? this.rotate;

    return PinSymbol(
      rotate: rotate,
      r: r1,
      itemStyle: itemStyle,
      borderStyle: borderStyle,
    );
  }
}
