import 'dart:math';
import 'dart:ui';

import '../../core/view_group.dart';
import '../../model/enums/direction.dart';

class LinearLayout extends ChartViewGroup {
  Direction direction;

  LinearLayout({this.direction = Direction.vertical});

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    num w = 0;
    num h = 0;
    for (var c in children) {
      c.measure(parentWidth, parentHeight);
    }
    for (var c in children) {
      if (direction == Direction.vertical) {
        w = max(w, c.width);
        h += c.height;
      } else {
        h = max(h, c.height);
        w += c.width;
      }
    }
    return Size(w.toDouble(), h.toDouble());
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    double left = 0;
    double top = 0;
    for (var c in children) {
      c.layout(left, top, left + c.width, top + c.height);
      if (direction == Direction.vertical) {
        top += c.height;
      } else {
        left += c.width;
      }
    }
  }
}
