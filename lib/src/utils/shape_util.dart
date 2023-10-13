import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///判断两圆是否相交
bool isIntersect(Circle a, Circle b) {
  return a.center.distance2(b.center) < a.r + b.r;
}

///计算两圆交点
List<Offset> computeCircleCrossPoint(Offset c1, num r1, Offset c2, num r2) {
  var disc = c1.distanceNotSqrt(c2.dx, c2.dy);
  var dis2 = r1 + r2;
  dis2 = dis2 * dis2;
  if (disc > dis2) {
    return [];
  }

  double dx = c1.dx - c2.dx;
  double dy = c1.dy - c2.dy;
  num r12 = r1 * r1;
  num r22 = r2 * r2;

  double d = sqrt(dx * dx + dy * dy);
  double l = (r12 - r22 + d * d) / (2 * d);
  double h2 = r12 - l * l;
  double h;
  if (h2.abs() <= 0.0000001) {
    h = 0;
  } else {
    h = sqrt(h2);
  }

  ///交点1
  double x1 = (c2.dx - c1.dx) * l / d + ((c2.dy - c1.dy) * h / d) + c1.dx;
  double y1 = (c2.dy - c1.dy) * l / d - (c2.dx - c1.dx) * h / d + c1.dy;

  ///交点2
  double x2 = (c2.dx - c1.dx) * l / d - ((c2.dy - c1.dy) * h / d) + c1.dx;
  double y2 = (c2.dy - c1.dy) * l / d + (c2.dx - c1.dx) * h / d + c1.dy;

  if ((x1 - x2).abs() < 1e-6 && (y1 - y2).abs() < 1e-6) {
    return [Offset(x1, y1)];
  }
  return [Offset(x1, y1), Offset(x2, y2)];
}
