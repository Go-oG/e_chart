import 'dart:math';

import 'package:flutter/material.dart';

import '../ext/offset_ext.dart';
import '../model/constans.dart';
import 'shape_element.dart';

class Arc implements ShapeElement {
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
  Path path(bool close) {
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
    double ir = innerRadius.toDouble();
    double or = outRadius.toDouble();
    double corner = min(cornerRadius, (or - ir) / 2).toDouble();
    num swa = sweepAngle;
    num sa = startAngle;
    double direction = sweepAngle > 0 ? 1 : -1;

    ///修正相关的角度
    if (swa.abs() > 360) {
      swa %= 360;
    }
    if (swa.abs() == 0 && sweepAngle.abs() > 0) {
      swa = 360 * direction;
    }

    num innerEndAngle = sa + swa;
    num outerEndAngle = innerEndAngle;

    bool largeArc = swa.abs() >= 180;
    bool hasCorner = corner > 0.001;
    bool circle = ir <= 0.001;

    Path path = Path();

    if (circle) {
      path.moveTo(center.dx, center.dy);
      if (!hasCorner) {
        Offset o1 = circlePoint(or, sa, center);
        Offset o2 = circlePoint(or, outerEndAngle, center);
        path.lineTo(o1.dx, o1.dy);
        path.arcToPoint(o2, radius: Radius.circular(or), largeArc: largeArc, clockwise: swa > 0);
      } else {
        if (swa > 0) {
          List<Offset> offsetList = _computeLT(or, corner, sa);
          Offset p1 = offsetList[0];
          Offset p2 = offsetList[1];
          path.lineTo(p1.dx, p1.dy);
          path.arcToPoint(p2, radius: Radius.circular(corner.toDouble()), largeArc: false, clockwise: true);

          offsetList = _computeRT(or, corner, outerEndAngle);
          p1 = offsetList[0];
          p2 = offsetList[1];
          path.arcToPoint(p1, radius: Radius.circular(or), largeArc: largeArc, clockwise: true);
          path.arcToPoint(p2, radius: Radius.circular(corner.toDouble()), largeArc: false, clockwise: true);
        } else {
          List<Offset> offsetList = _computeRT(or, corner, sa);
          Offset p1 = offsetList[0];
          Offset p2 = offsetList[1];
          path.lineTo(p2.dx, p2.dy);
          path.arcToPoint(p1, radius: Radius.circular(corner), largeArc: false, clockwise: false);
          offsetList = _computeLT(or, corner, outerEndAngle);
          p1 = offsetList[0];
          p2 = offsetList[1];
          path.arcToPoint(p2, radius: Radius.circular(or), largeArc: largeArc, clockwise: false);
          path.arcToPoint(p1, radius: Radius.circular(corner), largeArc: false, clockwise: false);
        }
      }
      path.close();
      return path;
    }

    ///修正存在angleGap时视觉上间隔不一致问题(只有为圆弧时才有效)
    if (padAngle > 0) {
      ///计算对应弧长
      double innerDiff = padAngle * Constants.angleUnit * ir;
      double outerDiff = padAngle * Constants.angleUnit * or;
      double outerAngleOffset = ((outerDiff - innerDiff) / (2 * pi * or)) * 360;
      if (swa < 0) {
        outerEndAngle -= outerAngleOffset;
      } else {
        outerEndAngle += outerAngleOffset;
      }
    }

    if ((outerEndAngle - sa).abs() >= 360) {
      Path p1 = Path();
      Offset o1 = circlePoint(or, sa, center);
      Offset o2 = circlePoint(or, sa + 360 * direction, center);
      p1.moveTo(o1.dx, o1.dy);
      p1.arcToPoint(o2, radius: Radius.circular(or), largeArc: true, clockwise: direction == 1);
      p1.close();
      Path p2 = Path();
      o1 = circlePoint(ir, sa, center);
      o2 = circlePoint(ir, sa + 360 * direction, center);
      p2.lineTo(o2.dx, o2.dy);
      p2.arcToPoint(o1, radius: Radius.circular(ir), largeArc: true, clockwise: direction != 1);
      p2.close();
      path = Path.combine(PathOperation.difference, p1, p2);
      return path;
    }

    ///圆弧
    if (!hasCorner) {
      bool clockwise = swa > 0;
      clockwise = outerEndAngle - sa > 0;
      Offset o1 = circlePoint(or, sa, center);
      Offset o2 = circlePoint(or, outerEndAngle, center);
      path.moveTo(o1.dx, o1.dy);
      path.arcToPoint(o2, radius: Radius.circular(or), largeArc: largeArc, clockwise: clockwise);
      o1 = circlePoint(ir, sa, center);
      o2 = circlePoint(ir, innerEndAngle, center);
      path.lineTo(o2.dx, o2.dy);
      path.arcToPoint(o1, radius: Radius.circular(ir), largeArc: largeArc, clockwise: !clockwise);
    } else {
      if (swa > 0) {
        ///leftTop
        List<Offset> offsetList = _computeLT(or, corner, sa);
        Offset p1 = offsetList[0];
        Offset p2 = offsetList[1];
        path.moveTo(p1.dx, p1.dy);
        path.arcToPoint(p2, radius: Radius.circular(corner.toDouble()), largeArc: false, clockwise: true);

        ///rightTop
        offsetList = _computeRT(or, corner, outerEndAngle);
        p1 = offsetList[0];
        p2 = offsetList[1];
        path.arcToPoint(p1, radius: Radius.circular(or), largeArc: largeArc, clockwise: true);
        path.arcToPoint(p2, radius: Radius.circular(corner.toDouble()), largeArc: false, clockwise: true);

        ///rightBottom
        offsetList = _computeRB(ir, corner, innerEndAngle);
        p1 = offsetList[0];
        p2 = offsetList[1];
        path.lineTo(p1.dx, p1.dy);
        path.arcToPoint(p2, radius: Radius.circular(corner.toDouble()), largeArc: false, clockwise: true);

        ///leftBottom
        offsetList = _computeLB(ir, corner, sa);
        p1 = offsetList[0];
        p2 = offsetList[1];
        path.arcToPoint(p1, radius: Radius.circular(ir), largeArc: largeArc, clockwise: false);
        path.arcToPoint(p2, radius: Radius.circular(corner.toDouble()), largeArc: false, clockwise: true);
      } else {
        ///rightTop
        List<Offset> offsetList = _computeRT(or, corner, sa);
        Offset p1 = offsetList[0];
        Offset p2 = offsetList[1];
        path.moveTo(p2.dx, p2.dy);
        path.arcToPoint(p1, radius: Radius.circular(corner), largeArc: false, clockwise: false);

        ///leftTop
        offsetList = _computeLT(or, corner, outerEndAngle);
        p1 = offsetList[0];
        p2 = offsetList[1];
        path.arcToPoint(p2, radius: Radius.circular(or), largeArc: largeArc, clockwise: false);
        path.arcToPoint(p1, radius: Radius.circular(corner), largeArc: false, clockwise: false);

        ///leftBottom
        offsetList = _computeLB(ir, corner, innerEndAngle);
        p1 = offsetList[0];
        p2 = offsetList[1];
        path.lineTo(p2.dx, p2.dy);
        path.arcToPoint(p1, radius: Radius.circular(corner), largeArc: false, clockwise: false);

        ///rightBottom
        offsetList = _computeRB(ir, corner, sa);
        p1 = offsetList[0];
        p2 = offsetList[1];
        path.arcToPoint(p2, radius: Radius.circular(ir), largeArc: largeArc, clockwise: true);
        path.arcToPoint(p1, radius: Radius.circular(corner), largeArc: false, clockwise: false);
      }
    }
    path.close();
    return path;
  }

  Path arcOpen() {
    double r = max(innerRadius, outRadius).toDouble();
    num oldSweepAngle = this.sweepAngle.abs();
    num sweepAngle = this.sweepAngle % 360;

    ///修复当扫过的角度==360度时绘制异常
    if (oldSweepAngle % 360 == 0 && oldSweepAngle != 0) {
      sweepAngle = 359.9999;
    }

    num sa = startAngle % 360;
    num endAngle = sa + sweepAngle;

    endAngle = endAngle % 360;
    bool largeArc = sweepAngle >= 180;
    Offset startOffset = circlePoint(r, sa, center);
    Offset endOffset = circlePoint(r, endAngle, center);
    Path path = Path();
    path.moveTo(startOffset.dx, startOffset.dy);
    path.arcToPoint(endOffset, radius: Radius.circular(r), largeArc: largeArc, clockwise: true);
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
    bx = -by * sin(angle * Constants.angleUnit);
    by = by * cos(angle * Constants.angleUnit);

    cx = outRadius * sin((angle + anglePCE) * Constants.angleUnit);
    cy = -outRadius * cos((angle + anglePCE) * Constants.angleUnit);

    return [Offset(bx, by), Offset(cx, cy)];
  }

  //计算圆弧右上顶角当有圆角时圆角切线两点的坐标
  List<Offset> _computeRT(num outRadius, num corner, num angle) {
    angle += 90;
    double tmpRadius = (outRadius - corner).toDouble();
    double angleCorner = asin(corner / tmpRadius) * 180 / pi; //夹角度数
    double oc = tmpRadius * cos(angleCorner * Constants.angleUnit);

    double bx = outRadius * sin((angle - angleCorner) * Constants.angleUnit);
    double by = -outRadius * cos((angle - angleCorner) * Constants.angleUnit);

    double cx = oc * sin(angle * Constants.angleUnit);
    double cy = -oc * cos(angle * Constants.angleUnit);

    return [Offset(bx, by), Offset(cx, cy)];
  }

  //计算圆弧左下顶角当有圆角时圆角切线两点的坐标
  List<Offset> _computeLB(num innerRadius, num corner, num angle) {
    angle += 90;
    double op = innerRadius + corner.toDouble();
    double eb = corner * innerRadius / op;
    double angleEOB = asin(eb / innerRadius) * 180 / pi;
    double sa = angle.toDouble();
    double bx = innerRadius * sin((sa + angleEOB) * Constants.angleUnit);
    double by = -innerRadius * cos((sa + angleEOB) * Constants.angleUnit);
    double oc = op * cos(angleEOB * Constants.angleUnit);
    double cx = oc * sin(sa * Constants.angleUnit);
    double cy = -op * cos(sa * Constants.angleUnit);
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
    double cx = innerRadius * sin(angleOPB);
    double cy = -innerRadius * cos(angleOPB);
    double bx = ob * sin(angle * Constants.angleUnit);
    double by = -ob * cos(angle * Constants.angleUnit);
    return [Offset(bx, by), Offset(cx, cy)];
  }
}
