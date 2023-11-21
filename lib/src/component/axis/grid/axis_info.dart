import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///描述一个轴的大小和位置
class AxisInfo {
  ///记录轴的起点和终点
  Offset start;
  Offset end;

  double width = 0;
  double height = 0;

  ///轴的边界信息
  AxisInfo(this.start, this.end);

  double get length => start.distance2(end);

  void reset() {
    start = end = Offset.zero;
    width = height = 0;
  }
}
