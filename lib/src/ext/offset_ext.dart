import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart';

extension OffsetExt on Offset {
  ///求两点之间的距离
  double distance2(Offset p) {
    double a = (dx - p.dx).abs();
    double b = (dy - p.dy).abs();
    return m.sqrt(a * a + b * b);
  }

  /// 判断点Q是否在由 p1 p2组成的线段上 允许偏移值
  /// [deviation] 偏差值必须大于等于0
  bool inLine(Offset p1, Offset p2, {double deviation = 4}) {
    return BaseLine(p1, p2).inLine(this, deviation: deviation);
  }

  //判断点是否在多边形内部(包含边界)
  bool inPolygon(List<Offset> list) {
    return Polygon(list).contains(this);
  }

  /// 判断点是否在一个扇形上
  /// 向量夹角公式
  bool inSector(
    num innerRadius,
    num outerRadius,
    num startAngle,
    num sweepAngle, {
    Offset center = Offset.zero,
  }) {
    double d1 = distance2(center);
    if (d1 > outerRadius || d1 < innerRadius) {
      return false;
    }
    if (sweepAngle.abs() >= 360) {
      return true;
    }

    Offset oA = circlePoint(d1, startAngle, center);
    Vector2 vectorA = Vector2(oA.dx - center.dx, oA.dy - center.dy);
    Offset oB = circlePoint(d1, startAngle + sweepAngle, center);
    Vector2 vectorB = Vector2(oB.dx - center.dx, oB.dy - center.dy);
    Vector2 vectorP = Vector2(dx - center.dx, dy - center.dy);

    if (vectorP.x == 0 && vectorP.y == 0) {
      return true;
    }

    ///精度(4位小数)
    var ab = (vectorA.angleToSigned(vectorB) * 1000).toInt();
    var ap = (vectorA.angleToSigned(vectorP) * 1000).toInt();

    bool result = ap <= ab;
    if (ap < 0 && ab < 0) {
      result = ap >= ab;
    } else if (ab > 0 && ap < 0) {
      result = false;
    }
    return result;
  }

  bool inArc(Arc arc) {
    return arc.contains(this);
  }

  bool inCircle(num radius, {Offset center = Offset.zero}) {
    return distance2(center) <= radius;
  }

  /// 给定圆心坐标求当前点的偏移角度
  /// 返回值为角度[0,360]
  double angle([Offset center = Offset.zero]) {
    double d = m.atan2(dy - center.dy, dx - center.dx);
    if (d < 0) {
      d += 2 * m.pi;
    }
    return d * 180 / m.pi;
  }

  ///返回绕center点旋转angle角度后的位置坐标
  ///逆时针 angle 为负数
  ///顺时针 angle 为正数
  Offset rotate(num angle, {Offset center = Offset.zero}) {
    angle = angle % 360;
    num t = angle * Constants.angleUnit;
    double x = (dx - center.dx) * m.cos(t) - (dy - center.dy) * m.sin(t) + center.dx;
    double y = (dx - center.dx) * m.sin(t) + (dy - center.dy) * m.cos(t) + center.dy;
    return Offset(x, y);
  }

  Offset translate2(Offset other) {
    return translate(other.dx, other.dy);
  }

  Offset get invert {
    return Offset(-dx, -dy);
  }
}

///给定一个半径和圆心计算给定角度对应的位置坐标
Offset circlePoint(num radius, num angle, [Offset center = Offset.zero]) {
  double x = center.dx + radius * m.cos(angle * Constants.angleUnit);
  double y = center.dy + radius * m.sin(angle * Constants.angleUnit);
  return Offset(x, y);
}
