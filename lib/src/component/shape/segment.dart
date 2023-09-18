import 'dart:math';
import 'dart:ui';

import 'package:e_chart/src/ext/offset_ext.dart';

import '../../model/chart_error.dart';
import '../../utils/log_util.dart';

///线段
class Segment {
  final Offset start;
  final Offset end;

  const Segment(this.start, this.end);

  /// 求点Q到直线的距离
  double distance(Offset p) {
    var dx = p.dx;
    var dy = p.dy;
    if (start.dx.compareTo(end.dx) == 0 && start.dy.compareTo(end.dy) == 0) {
      return p.distance2(start);
    }
    double A = end.dy - start.dy;
    double B = start.dx - end.dx;
    double C = end.dx * start.dy - start.dx * end.dy;
    return ((A * dx + B * dy + C) / (sqrt(A * A + B * B))).abs();
  }

  ///判断给定点是否在当前线段上
  bool contains(Offset p, {double deviation = 4}) {
    if (deviation < 0) {
      Logger.w('deviation must >= 0');
      deviation = 0;
    }
    var dx = p.dx;
    var dy = p.dy;
    if (dy > max(start.dy, end.dy) + deviation || dy < min(start.dy, end.dy) - deviation) {
      return false;
    }
    if (dx > max(start.dx, end.dx) + deviation || dx < min(start.dx, end.dx) - deviation) {
      return false;
    }
    return distance(p) <= deviation;
  }
}
