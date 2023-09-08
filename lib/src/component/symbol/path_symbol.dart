import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PathSymbol extends ChartSymbol {
  late final Path path;
  late final Rect bound;

  PathSymbol(this.path, {Rect? bound, super.itemStyle, super.borderStyle}) {
    this.bound = bound ?? path.getBounds();
  }

  @override
  void draw(Canvas canvas, Paint paint, Offset offset) {
    if (!checkStyle()) {
      return;
    }
    itemStyle?.drawPath(canvas, paint, path);
    borderStyle?.drawPath(canvas, paint, path);
  }

  @override
  bool contains(Offset center, Offset point) {
    return path.contains(point.translate2(center.invert));
  }

  @override
  Size get size => bound.size;

  @override
  ChartSymbol lerp(covariant ChartSymbol end, double t) {
    throw UnimplementedError();
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    return this;
  }
}
