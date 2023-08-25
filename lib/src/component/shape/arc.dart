import 'dart:math';

import 'package:flutter/material.dart';

import '../../ext/offset_ext.dart';

import '../../model/constans.dart';
import 'chart_shape.dart';

class Arc implements Shape {
  static const double circleMinAngle = 359.99;
  static const double cornerMin = 0.01;
  static const double innerMin = 0.001;

  final num innerRadius;
  final num outRadius;
  final num startAngle;
  final num sweepAngle;
  final num cornerRadius;
  final num padAngle;
  final Offset center;

  Arc({
    this.innerRadius = 0,
    this.outRadius = 0,
    this.startAngle = 0,
    this.sweepAngle = 0,
    this.cornerRadius = 0,
    this.padAngle = 0,
    this.center = Offset.zero,
  });

  Arc copy({
    num? innerRadius,
    num? outRadius,
    num? startAngle,
    num? sweepAngle,
    num? cornerRadius,
    num? padAngle,
    Offset? center,
  }) {
    return Arc(
      innerRadius: innerRadius ?? this.innerRadius,
      outRadius: outRadius ?? this.outRadius,
      startAngle: startAngle ?? this.startAngle,
      sweepAngle: sweepAngle ?? this.sweepAngle,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      padAngle: padAngle ?? this.padAngle,
      center: center ?? this.center,
    );
  }

  static Arc lerp(Arc begin, Arc end, double t) {
    double innerRadius = begin.innerRadius + (end.innerRadius - begin.innerRadius) * t;
    double outerRadius = begin.outRadius + (end.outRadius - begin.outRadius) * t;
    double startAngle = begin.startAngle + (end.startAngle - begin.startAngle) * t;
    double sweepAngle = begin.sweepAngle + (end.sweepAngle - begin.sweepAngle) * t;
    Offset center = Offset.lerp(begin.center, end.center, t)!;
    return Arc(
      innerRadius: innerRadius,
      outRadius: outerRadius,
      sweepAngle: sweepAngle,
      startAngle: startAngle,
      center: center,
    );
  }

  @override
  String toString() {
    return 'IR:${innerRadius.toStringAsFixed(1)} OR:${outRadius.toStringAsFixed(1)} SA:${startAngle.toStringAsFixed(1)} '
        'EA:${endAngle.toStringAsFixed(1)} center:$center';
  }

  double get endAngle => (startAngle + sweepAngle).toDouble();

  Offset centroid() {
    var r = (innerRadius + outRadius) / 2;
    var a = (startAngle + endAngle) / 2;
    return circlePoint(r, a, center);
  }

  num centerAngle() {
    return startAngle + (sweepAngle / 2);
  }

  bool get isEmpty {
    return (sweepAngle.abs()) == 0 || (outRadius - innerRadius).abs() == 0;
  }

  Path? _closePath;
  Path? _openPath;

  @override
  Path toPath(bool close) {
    if (close && _closePath != null) {
      return _closePath!;
    }
    if (!close && _openPath != null) {
      return _openPath!;
    }

    if (!close) {
      _openPath = arcOpen();
      return _openPath!;
    }
    _closePath = arc();
    return _closePath!;
  }

  Path arc() {
    final double ir = innerRadius <= 0.001 ? 0 : innerRadius.toDouble();
    final double or = outRadius.toDouble();
    final bool clockwise = sweepAngle >= 0;
    final int direction = sweepAngle > 0 ? 1 : -1;
    if (sweepAngle.abs() >= circleMinAngle) {
      return _buildCircle(center, startAngle, ir, or, direction);
    }

    double corner = min(cornerRadius, (or - ir) / 2).toDouble();
    corner = max(corner, 0);

    final num swa = sweepAngle;
    final double sa = startAngle.toDouble();
    final num inEndAngle = sa + swa;
    Rect orRect = Rect.fromCircle(center: center, radius: or);
    Rect irRect = Rect.fromCircle(center: center, radius: ir);
    Path path = Path();

    ///普通扇形
    if (ir <= innerMin) {
      ///扇形(忽略内部圆角)
      path.moveTo(center.dx, center.dy);
      double cor = corner;

      ///扫过角度对应的弧长度
      double dd = or * pi * swa.abs() / 180;
      if (dd / 2 < cor) {
        cor = dd / 2;
      }
      if (cor <= cornerMin) {
        //认为不会有圆角
        Offset o1 = circlePoint(or, sa, center);
        path.lineTo(o1.dx, o1.dy);
        double tmpAngle = swa.abs() * Constants.angleUnit;
        path.arcTo(orRect, sa * Constants.angleUnit, tmpAngle * direction, false);
        path.close();
        return path;
      }
      Radius cr = Radius.circular(cor);

      ///扇形外部有圆角
      if (clockwise) {
        ///leftTop->rightTop
        InnerOffset lt = _computeLT(or, corner, sa);
        InnerOffset rt = _computeRT(or, corner, inEndAngle);
        path.lineTo(lt.p1.dx, lt.p1.dy);
        path.arcToPoint(lt.p2, radius: cr, largeArc: false, clockwise: true);
        double a = lt.p2.offsetAngle(center) * Constants.angleUnit;
        double b = rt.p1.offsetAngle(center) * Constants.angleUnit;
        if (b < a) {
          b += 2 * pi;
        }
        path.arcTo(orRect, a, b - a, false);
        path.arcToPoint(rt.p2, radius: cr, largeArc: false, clockwise: true);
      } else {
        ///rightTop ->leftTop
        InnerOffset rt = _computeRT(or, corner, sa);
        InnerOffset lt = _computeLT(or, corner, inEndAngle);
        path.lineTo(rt.p2.dx, rt.p2.dy);
        path.arcToPoint(rt.p1, radius: cr, largeArc: false, clockwise: false);
        double a = rt.p1.offsetAngle(center) * Constants.angleUnit;
        double b = lt.p2.offsetAngle(center) * Constants.angleUnit;
        if (b > a) {
          b -= 2 * pi;
        }
        path.arcTo(orRect, a, b - a, false);
        path.arcToPoint(lt.p1, radius: cr, largeArc: false, clockwise: false);
      }
      path.close();
      return path;
    }

    ///环形扇区
    num outEndAngle = inEndAngle;

    ///修正存在angleGap时视觉上间隔不一致问题(只有innerRadius>0时有效)
    if (padAngle > 0 && ir > 0) {
      double diff = (or - ir) * (pi * padAngle / 180) * 0.7;
      double outOffset = (diff / (pi * or)) * 180;
      outEndAngle += outOffset * direction;
    }

    ///没有圆角
    if (corner < cornerMin) {
      Offset op = circlePoint(or, sa, center);
      path.moveTo(op.dx, op.dy);
      double swp = (outEndAngle - sa).abs() * Constants.angleUnit;
      path.arcTo(orRect, sa * Constants.angleUnit, swp * direction, true);

      ///inner
      Offset ip = circlePoint(ir, inEndAngle, center);
      path.lineTo(ip.dx, ip.dy);
      swp = (inEndAngle - sa).abs() * Constants.angleUnit;
      double tmpAngle = (clockwise ? inEndAngle : sa) * Constants.angleUnit;
      path.arcTo(irRect, tmpAngle, -1 * swp * direction, false);
      path.close();
      return path;
    }

    ///计算外圆环和内圆环的最小corner
    final num outLength = or * pi * swa.abs() / 180;
    final num inLength = ir * pi * swa.abs() / 180;
    double outCorner = corner;
    double inCorner = corner;
    if (corner * pi > outLength) {
      outCorner = outLength / pi;
    }
    if (corner * pi > inLength) {
      inCorner = inLength / pi;
    }

    if (clockwise) {
      if (outCorner >= cornerMin) {
        Radius ocr = Radius.circular(outCorner);

        ///leftTop ->rightTop
        InnerOffset lt = _computeLT(or, outCorner, sa);
        InnerOffset rt = _computeRT(or, outCorner, outEndAngle);
        path.moveTo(lt.p1.dx, lt.p1.dy);
        path.arcToPoint(lt.p2, radius: ocr, largeArc: false, clockwise: true);

        double a = lt.p2.offsetAngle(center) * Constants.angleUnit;
        double b = rt.p1.offsetAngle(center) * Constants.angleUnit;
        if (b < a) {
          b += 2 * pi;
        }
        path.arcTo(orRect, a, b - a, false);
        path.lineTo(rt.p1.dx, rt.p1.dy); //优化
        path.arcToPoint(rt.p2, radius: ocr, largeArc: false, clockwise: true);
      } else {
        Offset op = circlePoint(or, sa, center);
        path.moveTo(op.dx, op.dy);
        path.arcTo(orRect, sa * Constants.angleUnit, (outEndAngle - sa) * Constants.angleUnit, false);
      }
      if (inCorner >= cornerMin) {
        Radius icR = Radius.circular(inCorner);

        ///rightBottom ->leftBottom
        InnerOffset rb = _computeRB(ir, inCorner, inEndAngle);
        InnerOffset lb = _computeLB(ir, inCorner, sa);
        path.lineTo(rb.p1.dx, rb.p1.dy);
        path.arcToPoint(rb.p2, radius: icR, largeArc: false, clockwise: true);

        double a = rb.p2.offsetAngle(center) * Constants.angleUnit;
        double b = lb.p1.offsetAngle(center) * Constants.angleUnit;
        if (b > a) {
          b -= 2 * pi;
        }
        path.arcTo(irRect, a, b - a, false);
        path.lineTo(lb.p1.dx, lb.p1.dy); //优化
        path.arcToPoint(lb.p2, radius: icR, largeArc: false, clockwise: true);
      } else {
        Offset ip = circlePoint(ir, inEndAngle, center);
        path.lineTo(ip.dx, ip.dy);
        double t = (sa - inEndAngle) * Constants.angleUnit;
        path.arcTo(irRect, sa * Constants.angleUnit, t, false);
      }
      path.close();
      return path;
    }

    ///逆时针
    if (outCorner >= cornerMin) {
      ///rightTop->leftTop
      InnerOffset rt = _computeRT(or, outCorner, sa);
      InnerOffset lt = _computeLT(or, outCorner, outEndAngle);
      path.moveTo(rt.p2.dx, rt.p2.dy);
      path.arcToPoint(rt.p1, radius: Radius.circular(outCorner), largeArc: false, clockwise: false);
      double a = rt.p1.offsetAngle(center) * Constants.angleUnit;
      double b = lt.p2.offsetAngle(center) * Constants.angleUnit;
      if (b > a) {
        a += 2 * pi;
      }
      path.arcTo(orRect, a, b - a, false);
      path.lineTo(lt.p2.dx, lt.p2.dy);
      path.arcToPoint(lt.p1, radius: Radius.circular(outCorner), largeArc: false, clockwise: false);
    } else {
      Offset op = circlePoint(or, sa, center);
      path.moveTo(op.dx, op.dy);
      double t = (outEndAngle - sa).abs() * Constants.angleUnit;
      path.arcTo(orRect, sa * Constants.angleUnit, -t, false);
    }

    if (inCorner >= cornerMin) {
      ///leftBottom ->rightBottom
      InnerOffset lb = _computeLB(ir, inCorner, inEndAngle);
      InnerOffset rb = _computeRB(ir, inCorner, sa);
      path.lineTo(lb.p2.dx, lb.p2.dy);
      path.arcToPoint(lb.p1, radius: Radius.circular(inCorner), largeArc: false, clockwise: false);
      double a = lb.p1.offsetAngle(center) * Constants.angleUnit;
      double b = rb.p2.offsetAngle(center) * Constants.angleUnit;
      if (a > b) {
        a -= 2 * pi;
      }
      path.arcTo(irRect, a, (b - a).abs(), false);
      path.lineTo(rb.p2.dx, rb.p2.dy);
      path.arcToPoint(rb.p1, radius: Radius.circular(inCorner), largeArc: false, clockwise: false);
    } else {
      Offset ip = circlePoint(ir, inEndAngle, center);
      path.lineTo(ip.dx, ip.dy);
      double t = (inEndAngle - sa).abs() * Constants.angleUnit;
      path.arcTo(irRect, inEndAngle * Constants.angleUnit, t, true);
    }
    path.close();
    return path;
  }

  static Path _buildCircle(Offset center, num startAngle, double ir, double or, int direction) {
    const double sweep = 1.99999 * pi;

    ///直接为圆相关的
    Path outPath = Path();
    Offset o1 = circlePoint(or, startAngle, center);
    Rect orRect = Rect.fromCircle(center: center, radius: or);
    outPath.moveTo(o1.dx, o1.dy);
    outPath.arcTo(orRect, startAngle * Constants.angleUnit, sweep, false);
    outPath.close();
    if (ir <= innerMin) {
      return outPath;
    }

    Rect irRect = Rect.fromCircle(center: center, radius: ir);
    Path innerPath = Path();
    o1 = circlePoint(ir, startAngle, center);
    innerPath.arcTo(irRect, startAngle * Constants.angleUnit, sweep, false);
    innerPath.close();
    return Path.combine(PathOperation.difference, outPath, innerPath);
  }

  Path arcOpen() {
    double r = max(innerRadius, outRadius).toDouble();
    if (sweepAngle.abs() >= circleMinAngle) {
      return _buildCircle(center, startAngle, 0, r, sweepAngle > 0 ? 1 : -1);
    }

    Path path = Path();
    Offset op = circlePoint(r, startAngle, center);
    path.moveTo(op.dx, op.dy);
    path.arcTo(Rect.fromCircle(center: center, radius: r), startAngle * Constants.angleUnit, sweepAngle * Constants.angleUnit, false);
    return path;
  }

  InnerOffset _computeLT(num outRadius, num corner, num angle) {
    return _computeCornerPoint(center, outRadius, corner, angle, true, true);
  }

  InnerOffset _computeRT(num outRadius, num corner, num angle) {
    return _computeCornerPoint(center, outRadius, corner, angle, false, true);
  }

  InnerOffset _computeLB(num innerRadius, num corner, num angle) {
    return _computeCornerPoint(center, innerRadius, corner, angle, true, false);
  }

  InnerOffset _computeRB(num innerRadius, num corner, num angle) {
    return _computeCornerPoint(center, innerRadius, corner, angle, false, false);
  }

  ///计算切点位置
  static InnerOffset _computeCornerPoint(Offset center, num r, num corner, num angle, bool left, bool top) {
    InnerOffset result = InnerOffset();
    num dis = (r + corner * (top ? -1 : 1)).abs();
    double x = sqrt(dis * dis - corner * corner);
    Offset c = Offset(x, corner.toDouble() * (left ? 1 : -1));
    result.center = c.translate(center.dx, center.dy);
    Offset o1 = Offset(result.center.dx, center.dy);
    Offset o2 = computeCutPoint(center, r, result.center, corner);
    if (left != top) {
      Offset tmp = o1;
      o1 = o2;
      o2 = tmp;
    }
    result.p1 = o1;
    result.p2 = o2;

    ///旋转
    result.center = result.center.rotateOffset(angle, center: center);
    result.p1 = result.p1.rotateOffset(angle, center: center);
    result.p2 = result.p2.rotateOffset(angle, center: center);
    return result;
  }

  ///计算两个圆外切时的切点坐标
  static Offset computeCutPoint(Offset c1, num r1, Offset c2, num r2) {
    double dx = c1.dx - c2.dx;
    double dy = c1.dy - c2.dy;
    num r12 = r1 * r1;
    num r22 = r2 * r2;

    double d = sqrt(dx * dx + dy * dy);
    double l = (r12 - r22 + d * d) / (2 * d);
    double h2 = r12 - l * l;
    double h;
    if (h2.abs() <= 0.00001) {
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

    return Offset(x1, y1);
  }

  @override
  bool internal(Offset offset) {
    return offset.inArc(this);
  }
}

class InnerOffset {
  Offset center = Offset.zero;
  Offset p1 = Offset.zero;
  Offset p2 = Offset.zero;
}
