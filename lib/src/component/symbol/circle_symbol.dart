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
    return dis <= (scale*size.longestSide / 2);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (!checkStyle()) {
      return;
    }
    itemStyle.drawCircle(canvas, paint, Offset.zero, radius);
    borderStyle.drawCircle(canvas, paint, Offset.zero, radius);
  }

  @override
  CircleSymbol lerp(covariant CircleSymbol end, double t) {
    var or = lerpDouble(radius, end.radius, t)!;
    return CircleSymbol(
      radius: or,
      itemStyle: AreaStyle.lerp(itemStyle, end.itemStyle, t)??AreaStyle.empty,
      borderStyle: LineStyle.lerp(borderStyle, end.borderStyle, t)??LineStyle.empty,
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
