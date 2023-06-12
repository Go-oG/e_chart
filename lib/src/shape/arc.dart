import 'dart:math';

import 'package:flutter/material.dart';

import '../ext/offset_ext.dart';
import '../model/constans.dart';
import 'chart_shape.dart';

class Arc implements Shape {
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

  @override
  String toString() {
    return 'IR:${innerRadius.toStringAsFixed(1)} OR:${outRadius.toStringAsFixed(1)} startAngle${startAngle.toStringAsFixed(1)} '
        'endAngle:${endAngle.toStringAsFixed(1)} corner:${cornerRadius.toStringAsFixed(1)}';
  }

  double get endAngle => (startAngle + sweepAngle).toDouble();

  Offset centroid() {
    var r = (innerRadius + outRadius) / 2;
    var a = (startAngle + endAngle) / 2;
    return circlePoint(r, a, center);
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
    int direction = sweepAngle > 0 ? 1 : -1;
    if (sweepAngle.abs() >= 360) {
      return _buildCircle(ir, or, direction);
    }
    final bool clockwise = sweepAngle >= 0;

    double corner = min(cornerRadius, (or - ir) / 2).toDouble();
    corner = max(corner, 0);

    final num swa = sweepAngle;
    final double sa = startAngle.toDouble();
    final num inEndAngle = sa + swa;
    final bool largeArc = swa.abs() >= 180;

    Path path = Path();
    if (ir <= 0.001) {
      ///扇形(忽略内部圆角 OR 实现一个圆角拐角)
      path.moveTo(center.dx, center.dy);
      double cor = corner;

      ///扫过角度对应的弧长度
      double dd = or * 2 * pi * swa.abs() / 360;
      if (dd / 2 < cor) {
        cor = dd / 2;
      }
      if (cor <= 0.001) {
        //认为不会有圆角
        Offset o1 = circlePoint(or, sa, center);
        Offset o2 = circlePoint(or, inEndAngle, center);
        path.lineTo(o1.dx, o1.dy);
        path.arcToPoint(o2, radius: Radius.circular(or), largeArc: largeArc, clockwise: swa > 0);
        path.close();
        return path;
      }

      ///扇形外部有圆角
      Offset p1, p2;
      if (clockwise) {
        List<Offset> offsetList = _computeLT(or, corner, sa);
        p1 = offsetList[0];
        p2 = offsetList[1];
      } else {
        ///逆时针
        List<Offset> offsetList = _computeRT(or, corner, sa);
        p1 = offsetList[1];
        p2 = offsetList[0];
      }
      path.lineTo(p1.dx, p1.dy);
      path.arcToPoint(p2, radius: Radius.circular(corner.toDouble()), largeArc: false, clockwise: clockwise);
      if (swa >= 0) {
        List<Offset> offsetList = _computeRT(or, corner, inEndAngle);
        p1 = offsetList[0];
        p2 = offsetList[1];
      } else {
        List<Offset> offsetList = _computeLT(or, corner, inEndAngle);
        p1 = offsetList[1];
        p2 = offsetList[0];
      }
      path.arcToPoint(p1, radius: Radius.circular(or), largeArc: largeArc, clockwise: clockwise);
      path.arcToPoint(p2, radius: Radius.circular(corner.toDouble()), largeArc: false, clockwise: clockwise);
      path.close();
      return path;
    }

    ///环形扇区
    num outEndAngle = inEndAngle;

    ///修正存在angleGap时视觉上间隔不一致问题(只有innerRadius>0时有效)
    if (padAngle > 0) {
      num oldSw = swa.abs();
      double diff = padAngle * (or - ir);
      double angleDiff = diff / or;
      outEndAngle += angleDiff * direction;

      ///由于修正过后，扫过的角度可能会超过360，因此这里我们缩减到359.99
      if ((outEndAngle - sa).abs() >= 360) {
        if (oldSw < 359.99) {
          outEndAngle = sa + 359.99 * direction;
        } else {
          outEndAngle = inEndAngle;
        }
      }
    }

    ///没有圆角
    if (corner <= 0.001) {
      bool clockwise = swa > 0;
      clockwise = outEndAngle - sa > 0;
      Offset o1 = circlePoint(or, sa, center);
      Offset o2 = circlePoint(or, outEndAngle, center);
      path.moveTo(o1.dx, o1.dy);
      path.arcToPoint(o2, radius: Radius.circular(or), largeArc: largeArc, clockwise: clockwise);
      o1 = circlePoint(ir, sa, center);
      o2 = circlePoint(ir, inEndAngle, center);
      path.lineTo(o2.dx, o2.dy);
      path.arcToPoint(o1, radius: Radius.circular(ir), largeArc: largeArc, clockwise: !clockwise);
      path.close();
      return path;
    }

    Rect orRect = Rect.fromCircle(center: center, radius: or);
    Rect irRect = Rect.fromCircle(center: center, radius: ir);

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
      ///顺时针
      if (outCorner > 0) {
        ///leftTop
        List<Offset> offsetList = _computeLT(or, outCorner, sa);
        Offset p1 = offsetList[0];
        Offset p2 = offsetList[1];
        path.moveTo(p1.dx, p1.dy);
        path.arcToPoint(p2, radius: Radius.circular(outCorner), largeArc: false, clockwise: true);

        ///rightTop
        offsetList = _computeRT(or, outCorner, outEndAngle);
        p1 = offsetList[0];
        p2 = offsetList[1];
        path.arcToPoint(p1, radius: Radius.circular(or), largeArc: largeArc, clockwise: true);
        path.arcToPoint(p2, radius: Radius.circular(outCorner), largeArc: false, clockwise: true);
      } else {
        Offset op = circlePoint(or, sa, center);
        path.moveTo(op.dx, op.dy);
        path.arcTo(orRect, sa * Constants.angleUnit, (outEndAngle - sa) * Constants.angleUnit, true);
      }
      if (inCorner > 0) {
        ///rightBottom
        List<Offset> offsetList = _computeRB(ir, inCorner, inEndAngle);
        Offset p1 = offsetList[0];
        Offset p2 = offsetList[1];
        path.lineTo(p1.dx, p1.dy);
        path.arcToPoint(p2, radius: Radius.circular(inCorner), largeArc: false, clockwise: true);

        ///leftBottom
        offsetList = _computeLB(ir, inCorner, sa);
        p1 = offsetList[0];
        p2 = offsetList[1];
        path.arcToPoint(p1, radius: Radius.circular(ir), largeArc: largeArc, clockwise: false);
        path.arcToPoint(p2, radius: Radius.circular(inCorner), largeArc: false, clockwise: true);
      } else {
        Offset ip = circlePoint(ir, inEndAngle, center);
        path.lineTo(ip.dx, ip.dy);
        double t = (sa - inEndAngle) * Constants.angleUnit;
        path.arcTo(irRect, sa * Constants.angleUnit, t, true);
      }
      path.close();
      return path;
    }

    ///逆时针
    if (outCorner > 0) {
      ///rightTop
      List<Offset> offsetList = _computeRT(or, outCorner, sa);
      Offset p1 = offsetList[0];
      Offset p2 = offsetList[1];
      path.moveTo(p2.dx, p2.dy);
      path.arcToPoint(p1, radius: Radius.circular(outCorner), largeArc: false, clockwise: false);

      ///leftTop
      offsetList = _computeLT(or, outCorner, outEndAngle);
      p1 = offsetList[0];
      p2 = offsetList[1];
      path.arcToPoint(p2, radius: Radius.circular(or), largeArc: largeArc, clockwise: false);
      path.arcToPoint(p1, radius: Radius.circular(outCorner), largeArc: false, clockwise: false);
    } else {
      Offset op = circlePoint(or, sa, center);
      path.moveTo(op.dx, op.dy);
      double t = (outEndAngle - sa).abs() * Constants.angleUnit;
      path.arcTo(orRect, sa * Constants.angleUnit, -t, false);
    }

    if (inCorner > 0) {
      ///leftBottom
      List<Offset> offsetList = _computeLB(ir, inCorner, inEndAngle);
      Offset p1 = offsetList[0];
      Offset p2 = offsetList[1];
      path.lineTo(p2.dx, p2.dy);
      path.arcToPoint(p1, radius: Radius.circular(inCorner), largeArc: false, clockwise: false);

      ///rightBottom
      offsetList = _computeRB(ir, inCorner, sa);
      p1 = offsetList[0];
      p2 = offsetList[1];
      path.arcToPoint(p2, radius: Radius.circular(ir), largeArc: largeArc, clockwise: true);
      path.arcToPoint(p1, radius: Radius.circular(inCorner), largeArc: false, clockwise: false);
    } else {
      Offset ip = circlePoint(ir, inEndAngle, center);
      path.lineTo(ip.dx, ip.dy);
      double t = (inEndAngle - sa).abs() * Constants.angleUnit;
      path.arcTo(irRect, inEndAngle * Constants.angleUnit, t, true);
    }

    path.close();
    return path;
  }

  Path _buildCircle(double ir, double or, int direction) {
    ///直接为圆相关的
    Path outPath = Path();
    Offset o1 = circlePoint(or, startAngle, center);
    outPath.moveTo(o1.dx, o1.dy);
    outPath.arcTo(
      Rect.fromCircle(center: center, radius: or),
      startAngle * Constants.angleUnit,
      359.999 * direction * Constants.angleUnit,
      true,
    );
    outPath.close();
    if (ir <= 0.001) {
      return outPath;
    }
    Path innerPath = Path();
    o1 = circlePoint(ir, startAngle, center);
    innerPath.arcTo(
      Rect.fromCircle(center: center, radius: ir),
      startAngle * Constants.angleUnit,
      359.999 * direction * Constants.angleUnit,
      true,
    );
    innerPath.close();
    return Path.combine(PathOperation.difference, outPath, innerPath);
  }

  Path arcOpen() {
    double r = max(innerRadius, outRadius).toDouble();
    if (sweepAngle.abs() >= 360) {
      return _buildCircle(0, r, sweepAngle > 0 ? 1 : -1);
    }
    num sa = startAngle;
    Path path = Path();
    Offset op = circlePoint(r, sa, center);
    path.moveTo(op.dx, op.dy);
    path.arcTo(Rect.fromCircle(center: center, radius: r), sa * Constants.angleUnit, sweepAngle * Constants.angleUnit, false);
    return path;
  }

  //计算圆弧左上顶角当有圆角时的圆角切线两点的坐标
  List<Offset> _computeLT(num outRadius, num corner, num angle) {
    angle += 90;
    double pe = (corner * corner) / (outRadius - corner);
    double anglePCE = asin(pe / corner) * 180 / pi;
    double py = -(outRadius - corner) * sin((90 - anglePCE) * Constants.angleUnit);
    double px = (outRadius - corner) * cos((90 - anglePCE) * Constants.angleUnit);

    double by = py;
    double bx = px - corner;
    double cx = outRadius * sin(pe / corner);
    double cy = -outRadius * cos(pe / corner);

    ///调整偏移量
    bx = center.dx - by * sin(angle * Constants.angleUnit);
    by = center.dy + by * cos(angle * Constants.angleUnit);

    cx = center.dx + outRadius * sin((angle + anglePCE) * Constants.angleUnit);
    cy = center.dy - outRadius * cos((angle + anglePCE) * Constants.angleUnit);

    return [Offset(bx, by), Offset(cx, cy)];
  }

  //计算圆弧右上顶角当有圆角时圆角切线两点的坐标
  List<Offset> _computeRT(num outRadius, num corner, num angle) {
    angle += 90;
    double tmpRadius = (outRadius - corner).toDouble();
    double angleCorner = asin(corner / tmpRadius) * 180 / pi; //夹角度数
    double oc = tmpRadius * cos(angleCorner * Constants.angleUnit);

    double bx = center.dx + outRadius * sin((angle - angleCorner) * Constants.angleUnit);
    double by = center.dy - outRadius * cos((angle - angleCorner) * Constants.angleUnit);

    double cx = center.dx + oc * sin(angle * Constants.angleUnit);
    double cy = center.dy - oc * cos(angle * Constants.angleUnit);

    return [Offset(bx, by), Offset(cx, cy)];
  }

  //计算圆弧左下顶角当有圆角时圆角切线两点的坐标
  List<Offset> _computeLB(num innerRadius, num corner, num angle) {
    angle += 90;
    double op = innerRadius + corner.toDouble();
    double eb = corner * innerRadius / op;
    double angleEOB = asin(eb / innerRadius) * 180 / pi;
    double sa = angle.toDouble();
    double bx = center.dx + innerRadius * sin((sa + angleEOB) * Constants.angleUnit);
    double by = center.dy - innerRadius * cos((sa + angleEOB) * Constants.angleUnit);
    double oc = op * cos(angleEOB * Constants.angleUnit);
    double cx = center.dx + oc * sin(sa * Constants.angleUnit);
    double cy = center.dy - op * cos(sa * Constants.angleUnit);
    return [Offset(bx, by), Offset(cx, cy)];
  }

  //计算圆弧右下顶角当有圆角时圆角切线两点的坐标
  List<Offset> _computeRB(num innerRadius, num corner, num angle) {
    angle += 90;
    double op = innerRadius + corner.toDouble();
    double ec = corner * innerRadius / op;
    double angleEOC = (asin(ec / innerRadius) * 180 / pi);
    double ob = op * cos(angleEOC * Constants.angleUnit);
    double angleOPB = (angle - angleEOC) * Constants.angleUnit;
    double cx = center.dx + innerRadius * sin(angleOPB);
    double cy = center.dy - innerRadius * cos(angleOPB);
    double bx = center.dx + ob * sin(angle * Constants.angleUnit);
    double by = center.dy - ob * cos(angle * Constants.angleUnit);
    return [Offset(bx, by), Offset(cx, cy)];
  }
}
