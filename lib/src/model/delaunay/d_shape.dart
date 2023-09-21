import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于存储delaunay的数据
class DShape extends Polygon {
  static final DShape zero = DShape(-1, []);
  final int index;

  DShape(this.index, Iterable<ChartOffset> points) : super.from(points, false);

  bool get isEmpty => index < 0 || points.isEmpty;
}
