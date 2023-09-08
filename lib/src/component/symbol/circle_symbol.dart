import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CircleSymbol extends ChartSymbol {
  final num radius;

  CircleSymbol({
    this.radius = 8,
    super.borderStyle,
    super.itemStyle,
  });

  @override
  Size get size => Size.square(radius * 2);

  @override
  bool contains(Offset center, Offset point) {
    double dis = point.distance2(center);
    return dis <= (size.longestSide / 2);
  }

  @override
  void draw(Canvas canvas, Paint paint, Offset offset) {
    if (!checkStyle()) {
      return;
    }
    itemStyle?.drawCircle(canvas, paint, offset, radius);
    borderStyle?.drawCircle(canvas, paint, offset, radius);
  }

  @override
  CircleSymbol lerp(covariant CircleSymbol end, double t) {
    var or = lerpDouble(radius, end.radius, t)!;
    return CircleSymbol(
      radius: or,
      itemStyle: AreaStyle.lerp(itemStyle, end.itemStyle, t),
      borderStyle: LineStyle.lerp(borderStyle, end.borderStyle, t),
    );
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    if (attr == null || attr.isEmpty || attr.size == null) {
      return this;
    }
    num size = attr.size!.shortestSide;
    if (size <= 0) {
      size = attr.size!.longestSide;
    }
    if (size <= 0) {
      return this;
    }

    return CircleSymbol(radius: size, itemStyle: itemStyle, borderStyle: borderStyle);
  }
}
