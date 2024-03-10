import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///用于实现极坐标系
///支持 柱状图 折线图 散点图
class PolarCoordImpl extends PolarCoord {
  AngleAxisImpl? _angleAxis;

  AngleAxisImpl get angleAxis => _angleAxis!;

  RadiusAxisRender? _radiusAxis;

  RadiusAxisRender get radiusAxis => _radiusAxis!;

  Offset center = Offset.zero;

  PolarCoordImpl(super.props);

  @override
  void onCreate() {
    super.onCreate();
    _angleAxis = AngleAxisImpl(context, props.angleAxis, axisIndex: 0);
    _radiusAxis = RadiusAxisRender(context, props.radiusAxis, axisIndex: 0);
  }

  @override
  void onDispose() {
    _angleAxis?.dispose();
    _angleAxis = null;
    _radiusAxis?.dispose();
    _radiusAxis = null;
    super.onDispose();
  }

  @override
  void onHoverStart(Offset offset) {}

  @override
  void onHoverMove(Offset offset, Offset last) {}

  Size measureSize = Size.zero;

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double size = m.min(parentWidth, parentHeight);
    measureSize = Size(parentWidth, parentHeight);
    size = props.radius.last.convert(size) * 2;
    angleAxis.onMeasure(size, size);
    radiusAxis.onMeasure(size, size);
    return Size.square(size);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    center = Offset(props.center[0].convert(width), props.center[1].convert(height));
    contentBox = Rect.fromCircle(center: center, radius: width / 2);
    double size = m.min(measureSize.width, measureSize.height);
    double ir = props.radius.length > 1 ? props.radius.first.convert(size) : 0;
    double or = width / 2;

    var angleAttrs = AngleAxisAttrs(
      center,
      props.angleAxis.offsetAngle.toDouble(),
      [ir, or],
      scaleRatio: scaleY,
      scrollY: translationY,
      clockwise: props.angleAxis.clockwise,
    );

    angleAxis.doLayout(angleAttrs, _getAngleDataSet());

    num angle = props.radiusAxis.offsetAngle;
    Offset so = ir <= 0 ? center : circlePoint(ir, angle, center);
    Offset eo = circlePoint(or, angle, center);

    var radiusAttrs = RadiusAxisAttrs(center, angle, contentBox, so, eo);
    radiusAxis.doLayout(radiusAttrs, _getRadiusDataSet());

    for (var c in children) {
      c.layout(0, 0, width, height);
    }
  }

  List<dynamic> _getAngleDataSet() {
    List<dynamic> list = [];
    for (var child in children) {
      if (child is! PolarChild) {
        continue;
      }
      PolarChild c = child as PolarChild;
      list.addAll(c.getPolarExtreme(false));
    }
    return list;
  }

  List<dynamic> _getRadiusDataSet() {
    List<dynamic> list = [];
    for (var child in children) {
      if (child is! PolarChild) {
        continue;
      }
      PolarChild c = child as PolarChild;
      list.addAll(c.getPolarExtreme(true));
    }
    return list;
  }

  @override
  void onDraw(CCanvas canvas) {
    angleAxis.draw(canvas, mPaint);
    radiusAxis.draw(canvas, mPaint);
  }

  @override
  PolarPosition dataToPosition(dynamic radiusData, dynamic angleData) {
    checkDataType(radiusData);
    checkDataType(angleData);
    List<num> angles = angleAxis.dataToAngle(angleData);
    List<num> r = radiusAxis.dataToRadius(radiusData);
    if (props.radius.length > 1) {
      double ir = radiusAxis.attrs.start.distance2(radiusAxis.attrs.center);
      for (int i = 0; i < r.length; i++) {
        r[i] = r[i] + ir;
      }
    }
    return PolarPosition(center, r, angles);
  }

  @override
  Offset getCenter() => center;

  @override
  BaseScale<dynamic, num> getScale(bool angleAxis) {
    if (angleAxis) {
      return this.angleAxis.scale;
    }
    return radiusAxis.scale;
  }

  @override
  num getStartAngle() {
    return angleAxis.axis.offsetAngle;
  }

  @override
  List<double> getRadius() {
    return angleAxis.attrs.radius;
  }

  @override
  PolarPosition dataToAnglePosition(dynamic angleData) {
    checkDataType(angleData);
    List<num> angles = angleAxis.dataToAngle(angleData);
    return PolarPosition(center, [], angles);
  }

  @override
  PolarPosition dataToRadiusPosition(dynamic radiusData) {
    checkDataType(radiusData);
    List<num> r = radiusAxis.dataToRadius(radiusData);
    if (props.radius.length > 1) {
      double ir = radiusAxis.attrs.start.distance2(radiusAxis.attrs.center);
      for (int i = 0; i < r.length; i++) {
        r[i] = r[i] + ir;
      }
    }
    return PolarPosition(center, r, []);
  }

  @override
  num getSweepAngle() {
    return 360;
  }

  @override
  double getMaxXScroll() {
    return 0;
  }

  @override
  double getMaxYScroll() {
    return 0;
  }

  @override
  AxisType get angleAxisType => angleAxis.axisType;

  @override
  AxisType get radiusAxisType => radiusAxis.axisType;
}

abstract class PolarCoord extends CircleCoordLayout<Polar> {
  PolarCoord(super.props);

  PolarPosition dataToPosition(dynamic radiusData, dynamic angleData);

  PolarPosition dataToRadiusPosition(dynamic radiusData);

  PolarPosition dataToAnglePosition(dynamic angleData);

  Offset getCenter();

  List<double> getRadius();

  num getSweepAngle();

  num getStartAngle();

  BaseScale getScale(bool angleAxis);

  AxisType get radiusAxisType;

  AxisType get angleAxisType;
}

class PolarPosition {
  final Offset center;

  ///当radius是一个范围时起长度为2 否则为1
  final List<num> radius;

  ///当angle是一个范围时起长度为2 否则为1
  final List<num> angle;

  const PolarPosition(this.center, this.radius, this.angle);

  @override
  String toString() {
    return "$runtimeType $center radius:$radius angle:$angle";
  }

  Offset get position {
    num a;
    if (angle.length >= 2) {
      a = (angle.first + angle.last) / 2;
    } else {
      a = angle.first;
    }
    num r;
    if (radius.length >= 2) {
      r = (radius.first + radius.last) / 2;
    } else {
      r = radius.last;
    }

    return circlePoint(r, a, center);
  }
}
