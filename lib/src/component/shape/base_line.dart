import 'dart:math';
import 'dart:ui';

import 'package:e_chart/src/ext/offset_ext.dart';

import '../../model/chart_error.dart';

class BaseLine {
  final Offset start;
  final Offset end;

  BaseLine(this.start, this.end);

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

  bool inLine(Offset p, {double deviation = 4}) {
    if (deviation < 0) {
      throw ChartError('偏差值必须大于等于0');
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
