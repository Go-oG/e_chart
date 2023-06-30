import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///描述一个轴的大小和位置
class AxisInfo {
  final Direction direction;

  ///记录轴的起点和终点
  Offset start;
  Offset end;

  ///轴的边界信息
  Rect bound;
  double scaleFactory = 1;

  AxisInfo(this.direction, this.start, this.end, this.bound);

  double get length => start.distance2(end);
}
