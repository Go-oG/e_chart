import 'dart:ui';

import '../shape/star.dart';
import '../style/area_style.dart';
import '../style/index.dart';
import 'chart_symbol.dart';

class StarSymbol extends ChartSymbol {
  Star star;
  AreaStyle? itemStyle;
  LineStyle? lineStyle;

  StarSymbol(this.star);

  @override
  void draw2(Canvas canvas, Paint paint, Offset offset, Size size) {
    if (star.center != offset || star.or * 2 != size.longestSide) {
      star =
          Star(offset, star.count, star.ir, size.longestSide / 2, angleOffset: star.angleOffset, inside: star.inside);
    }
    itemStyle?.drawPath(canvas, paint, star.toPath(true));
    lineStyle?.drawPath(canvas, paint, star.toPath(true));
  }

  @override
  bool internal2(Offset center, Size size, Offset point) {
    return star.contains(point);
  }

  @override
  Size get size => Size.square(star.or * 2);
}
