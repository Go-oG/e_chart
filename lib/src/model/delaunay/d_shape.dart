import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于存储delaunay的数据
class DShape extends Polygon {
  static final DShape zero = DShape(-1, []);
  final int index;
  Path? path;

  DShape(this.index, Iterable<ChartOffset> points) : super.from(points, false);

  bool get isEmpty => index < 0 || points.isEmpty;

  @override
  bool contains(Offset offset) {
    if (path != null) {
      return path!.contains(offset);
    }
    return super.contains(offset);
  }

  @override
  Rect getBound() {
    if (path != null) {
      return path!.getBounds();
    }
    return super.getBound();
  }

  @override
  void dispose() {
    path = null;
    super.dispose();
  }
}
