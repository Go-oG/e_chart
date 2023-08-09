import 'dart:ui';

import 'package:e_chart/e_chart.dart';

extension RectExt on Rect {
  bool contains2(Offset offset) {
    return offset.dx >= left && offset.dx <= right && offset.dy >= top && offset.dy <= bottom;
  }

  RRect toRRect(Corner corner) {
    var lt = Radius.circular(corner.leftTop);
    var rt = Radius.circular(corner.rightTop);
    var lb = Radius.circular(corner.leftBottom);
    var rb = Radius.circular(corner.rightBottom);
    return RRect.fromRectAndCorners(this, topLeft: lt, topRight: rt, bottomLeft: lb, bottomRight: rb);
  }
}
