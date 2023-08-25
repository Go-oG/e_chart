import 'dart:math' as m;
import 'package:flutter/widgets.dart';
import 'package:vector_math/vector_math.dart';
import '../component/shape/arc.dart';
import '../model/constans.dart';


extension OffsetExt on Offset {
  ///求两点之间的距离
  double distance2(Offset p) {
    double a = (dx - p.dx).abs();
    double b = (dy - p.dy).abs();
    return m.sqrt(a * a + b * b);
  }

  /// 求点Q到直线的距离
  double lineDistance(Offset p1, Offset p2) {
    if (p1.dx.compareTo(p2.dx) == 0 && p1.dy.compareTo(p2.dy) == 0) {
      return distance2(p1);
    }
    double A = p2.dy - p1.dy;
    double B = p1.dx - p2.dx;
    double C = p2.dx * p1.dy - p1.dx * p2.dy;
    return ((A * dx + B * dy + C) / (m.sqrt(A * A + B * B))).abs();
  }

  /// 判断点Q是否在由 p1 p2组成的线段上 允许偏移值
  /// [deviation] 偏差值必须大于等于0
  bool inLine(Offset p1, Offset p2, {double deviation = 4}) {
    if (deviation < 0) {
      throw FlutterError('偏差值必须大于等于0');
    }
    if (dy > m.max(p1.dy, p2.dy) + deviation || dy < m.min(p1.dy, p2.dy) - deviation) {
      return false;
    }
    if (dx > m.max(p1.dx, p2.dx) + deviation || dx < m.min(p1.dx, p2.dx) - deviation) {
      return false;
    }
    double distance = lineDistance(p1, p2);
    return distance <= deviation;
  }

  //判断点是否在矩形内部
  bool inRect(Rect rect) {
    return inPolygon([
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      Offset(rect.left, rect.bottom),
    ]);
  }

  //判断点是否在多边形内部(包含边界)
  bool inPolygon(List<Offset> list) {
    if (list.isEmpty) {
      return false;
    }
    if (list.length == 1) {
      Offset p1 = list[0];
      double a = (dx - p1.dx).abs();
      double b = (dy - p1.dy).abs();
      return m.sqrt(a * a + b * b) <= 0.01;
    }
    if (list.length == 2) {
      return inLine(list[0], list[1], deviation: 0.05);
    }
    return inPolygonInner(list) || inPolygonBorder(list);
  }

  //参考百度地图(BaiduMap)的判断
  /// 返回一个点是否在一个多边形区域内
  bool inPolygonInner(List<Offset> mPoints) {
    int nCross = 0;
    for (int i = 0; i < mPoints.length; i++) {
      Offset p1 = mPoints[i];
      Offset p2 = mPoints[((i + 1) % mPoints.length)];
      if (p1.dy == p2.dy) {
        continue;
      }

      if (dy < m.min(p1.dy, p2.dy)) {
        continue;
      }
      if (dy >= m.max(p1.dy, p2.dy)) {
        continue;
      }

      double x = (dy - p1.dy) * (p2.dx - p1.dx) / (p2.dy - p1.dy) + p1.dx;
      if (x > dx) {
        //只统计单边交点
        nCross++;
      }
    }
    return (nCross % 2 == 1);
  }

  /// 返回一个点是否在一个多边形边界上
  bool inPolygonBorder(List<Offset> mPoints) {
    for (int i = 0; i < mPoints.length; i++) {
      Offset p1 = mPoints[i];
      Offset p2 = mPoints[((i + 1) % mPoints.length)];
      if (dy < m.min(p1.dy, p2.dy)) {
        continue;
      }
      if (dy > m.max(p1.dy, p2.dy)) {
        continue;
      }
      if (p1.dy == p2.dy) {
        double minX = m.min(p1.dx, p2.dx);
        double maxX = m.max(p1.dx, p2.dx);
// point在水平线段p1p2上,直接return true
        if ((dy == p1.dy) && (dx >= minX && dx <= maxX)) {
          return true;
        }
      } else {
        // 求解交点
        double x = (dy - p1.dy) * (p2.dx - p1.dx) / (p2.dy - p1.dy) + p1.dx;
        if (x == dx) {
          return true;
        }
      }
    }
    return false;
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
    return inSector(arc.innerRadius, arc.outRadius, arc.startAngle, arc.sweepAngle, center: arc.center);
  }

  bool inCircle(num radius, {Offset center = Offset.zero}) {
    return distance2(center) <= radius;
  }

  /// 给定一个点的坐标和圆心坐标求，求点的偏移角度
  double offsetAngle([Offset center = Offset.zero]) {
    double d = m.atan2(dy - center.dy, dx - center.dx);
    if (d < 0) {
      d += 2 * m.pi;
    }
    return d * 180 / m.pi;
  }

  ///返回绕center点旋转angle角度后的位置坐标
  ///逆时针 angle 为负数
  ///顺时针 angle 为正数
  Offset rotateOffset(num angle, {Offset center = Offset.zero}) {
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
