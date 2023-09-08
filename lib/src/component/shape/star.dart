import 'dart:math';
import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

///N角星形图案
class Star implements Shape {
  final Offset center;
  late final num count;
  final num ir;
  final num or;
  final num angleOffset;

  ///是否朝内 true时为圆内螺线 false 为凸形
  ///且当为 true时,ir将无效
  final bool inside;

  Star(
    this.center,
    num count,
    this.ir,
    this.or, {
    this.angleOffset = 0,
    this.inside = false,
  }) {
    if (inside) {
      if (ir <= 0) {
        this.count = 3;
      } else {
        this.count = (or / ir) - 1;
      }
    } else {
      this.count = count;
    }
  }

  Path? _path;

  @override
  Path toPath() {
    if (_path != null) {
      return _path!;
    }
    return _path = inside ? _buildInsidePath() : _buildOutPath();
  }

  Path _buildInsidePath() {
    Path path = Path();
    for (int i = 0; i <= 360; i++) {
      num a = angleOffset + i;
      a *= Constants.angleUnit;
      double x = cos(a) + cos(count * a) / count;
      double y = sin(a) - sin(count * a) / count;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    if (center != Offset.zero) {
      Matrix4 matrix4 = Matrix4.translationValues(-center.dx, -center.dy, 0);
      path.transform(matrix4.storage);
    }
    return path;
  }

  Path _buildOutPath() {
    double offset = 180 / count;
    List<Offset> outPoints = [];
    double rotate = -90 + angleOffset.toDouble();
    for (int i = 0; i < count; i++) {
      double perRad = 360 / count * i;
      outPoints.add(circlePoint(or, perRad + rotate, center));
      outPoints.add(circlePoint(ir, perRad + rotate + offset, center));
    }
    Path p = Path();
    for (int i = 0; i < outPoints.length; i++) {
      var offset = outPoints[i];
      if (i == 0) {
        p.moveTo(offset.dx, offset.dy);
      } else {
        p.lineTo(offset.dx, offset.dy);
      }
    }
    p.close();
    return p;
  }

  @override
  bool contains(Offset offset) {
    return toPath().contains(offset);
  }

  @override
  bool get isClosed => true;

  static Star lerp(Star s, Star e, double t) {
    var center = (s.center == e.center) ? e.center : Offset.lerp(s.center, e.center, t)!;
    var count = lerpDouble(s.count, e.count, t)!;
    num ir = lerpDouble(s.ir, e.ir, t)!;
    num or = lerpDouble(s.or, e.or, t)!;
    num angleOffset = lerpDouble(s.angleOffset, e.angleOffset, t)!;
    return Star(center, count, ir, or, angleOffset: angleOffset, inside: e.inside);
  }
}
