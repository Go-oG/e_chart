import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class SectorSymbol extends ChartSymbol {
  final num ir;
  final num or;
  late Arc arc;

  SectorSymbol(this.ir, this.or, {super.itemStyle, super.borderStyle}) {
    arc = Arc(innerRadius: ir, outRadius: or, sweepAngle: 360);
  }

  @override
  bool contains(Offset center, Offset point) {
    return arc.contains(point.translate(-center.dx, -center.dy));
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    var size = attr?.size;
    if (attr == null || attr.isEmpty || size == null) {
      return this;
    }
    num ir = size.shortestSide * 0.5;
    var or = size.longestSide * 0.5;
    return SectorSymbol(ir, or, itemStyle: itemStyle, borderStyle: borderStyle);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    itemStyle.drawArc(canvas, paint, arc);
    borderStyle.drawPath(canvas, paint, arc.toPath());
  }

  @override
  ChartSymbol lerp(covariant SectorSymbol end, double t) {
    return SectorSymbol(
      lerpDouble(ir, end.ir, t)!,
      lerpDouble(or, end.or, t)!,
      itemStyle: AreaStyle.lerp(itemStyle, end.itemStyle, t)??AreaStyle.empty,
      borderStyle: LineStyle.lerp(borderStyle, end.borderStyle, t)??LineStyle.empty,
    );
  }

  @override
  Size get size => Size.square(or.toDouble());
}
