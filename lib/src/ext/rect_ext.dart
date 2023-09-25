import 'dart:ui';
import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';

extension RectExt on Rect {
  bool contains2(Offset offset) {
    return offset.dx >= left && offset.dx <= right && offset.dy >= top && offset.dy <= bottom;
  }

  bool contains3(num x, num y) {
    return x >= left && x <= right && y >= top && y <= bottom;
  }

  ///判断当前矩形是否和给定圆有交点
  bool overlapCircle(Offset center, num radius) {
    return overlapCircle2(center.dx, center.dy, radius);
  }

  bool overlapCircle2(double cx, double cy, num radius) {
    if (contains3(cx, cy)) {
      return true;
    }

    ///https://blog.csdn.net/noahzuo/article/details/52037151
    ///右上角顶点向量a
    var hx = width * 0.5;
    var hy = height * 0.5;

    ///翻转圆心到第一象限并求圆心间向量
    var vx = (center.dx - cx).abs();
    var vy = (center.dy - cy).abs();

    var cx2 = m.max(vx - hx, 0);
    var cy2 = m.max(vy - hy, 0);
    return (cx2 * cx2 + cy2 * cy2) <= radius * radius;
  }

  ///判断当前矩形是否和给定的线段重合
  bool overlapLine(Offset p0, Offset p1) {
    if (contains2(p0) || contains2(p1)) {
      return true;
    }
    return lineOverlapLine(p0, p1, topLeft, bottomRight);
  }

  RRect toRRect(Corner corner) {
    var lt = Radius.circular(corner.leftTop);
    var rt = Radius.circular(corner.rightTop);
    var lb = Radius.circular(corner.leftBottom);
    var rb = Radius.circular(corner.rightBottom);
    return RRect.fromRectAndCorners(this, topLeft: lt, topRight: rt, bottomLeft: lb, bottomRight: rb);
  }
}

///判断两条线段是否相交
bool lineOverlapLine(Offset p0, Offset p1, Offset p2, Offset p3) {
  ///若有某一点重合，则肯定相交
  if (p0 == p2 || p0 == p3 || p1 == p2 || p1 == p3) {
    return true;
  }

  ///计算叉乘的结果
  double cross(Offset p1, Offset p2, Offset p3) {
    var x1 = p2.dx - p1.dx;
    var y1 = p2.dy - p1.dy;
    var x2 = p3.dx - p1.dx;
    var y2 = p3.dy - p1.dy;
    return x1 * y2 - x2 * y1;
  }

  bool onSegment(Offset p, List<Offset> seg) {
    var a = seg[0];
    var b = seg[1];
    var x = p.dx;
    var y = p.dy;
    return (x >= m.min(a.dx, b.dx) && x <= m.max(a.dx, b.dx) && y >= m.min(a.dy, b.dy) && y <= m.max(a.dy, b.dy));
  }

  var d1 = cross(p0, p1, p2);
  var d2 = cross(p0, p1, p3);
  var d3 = cross(p2, p3, p0);
  var d4 = cross(p2, p3, p1);

  if (d1 * d2 < 0 && d3 * d4 < 0) {
    return true;
  }

  // d1 为 0 表示 C 点在 AB 所在的直线上
  // 接着会用 onSegment 再判断这个 C 是不是在 AB 的 x 和 y 的范围内
  if (d1 == 0 && onSegment(p2, [p0, p1])) return true;
  if (d2 == 0 && onSegment(p3, [p0, p1])) return true;
  if (d3 == 0 && onSegment(p0, [p2, p3])) return true;
  if (d4 == 0 && onSegment(p1, [p2, p3])) return true;
  return false;
}
