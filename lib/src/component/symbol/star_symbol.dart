import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class StarSymbol extends ChartSymbol {
  final Star star;

  StarSymbol(
    this.star, {
    super.borderStyle,
    super.itemStyle,
  });

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (!checkStyle()) {
      return;
    }

    itemStyle.drawPath(canvas, paint, star.toPath());
    borderStyle.drawPath(canvas, paint, star.toPath());
  }

  @override
  bool contains(Offset center, Offset point) {
    return star.contains(point.translate2(center.invert));
  }

  @override
  Size get size => Size.square(star.or * 2);

  @override
  ChartSymbol lerp(covariant StarSymbol end, double t) {
    return StarSymbol(
      Star.lerp(star, end.star, t),
      itemStyle: AreaStyle.lerp(itemStyle, end.itemStyle, t) ,
      borderStyle: LineStyle.lerp(borderStyle, end.borderStyle, t),
    );
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    var ir = (attr?.size?.shortestSide ?? star.ir * 2) / 2;
    var or = (attr?.size?.longestSide ?? star.or * 2) / 2;
    Star rs = Star(star.center, attr?.borderCount ?? star.count, ir, or);
    return StarSymbol(rs, itemStyle: itemStyle, borderStyle: borderStyle);
  }
}
