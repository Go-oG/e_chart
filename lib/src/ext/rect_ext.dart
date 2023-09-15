import 'dart:math';
import 'dart:ui';
import '../model/corner.dart';

extension RectExt on Rect {
  bool contains2(Offset offset) {
    return offset.dx >= left && offset.dx <= right && offset.dy >= top && offset.dy <= bottom;
  }

  ///判断当前矩形是否和给定圆有交点
  bool containsCircle(Offset center, num radius) {
    if (contains2(center)) {
      return true;
    }

    ///https://blog.csdn.net/noahzuo/article/details/52037151
    ///右上角顶点向量a
    var hx = width * 0.5;
    var hy = height * 0.5;

    ///翻转圆心到第一象限并求圆心间向量
    var vx = (center.dx - this.center.dx).abs();
    var vy = (center.dy - this.center.dy).abs();

    var cx = max(vx - hx, 0);
    var cy = max(vy - hy, 0);
    return (cx * cx + cy * cy) <= radius * radius;
  }

  RRect toRRect(Corner corner) {
    var lt = Radius.circular(corner.leftTop);
    var rt = Radius.circular(corner.rightTop);
    var lb = Radius.circular(corner.leftBottom);
    var rb = Radius.circular(corner.rightBottom);
    return RRect.fromRectAndCorners(this, topLeft: lt, topRight: rt, bottomLeft: lb, bottomRight: rb);
  }
}
