import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///用于实现极坐标系
///支持 柱状图 折线图 散点图
class PolarCoordImpl extends PolarCoord {
  AngleAxisView? _angleAxis;

  AngleAxisView get angleAxis => _angleAxis!;

  RadiusAxisView? _radiusAxis;

  RadiusAxisView get radiusAxis => _radiusAxis!;

  Offset center = Offset.zero;

  PolarCoordImpl(super.context, super.props) {
    _angleAxis = AngleAxisView(context, props.angleAxis, axisIndex: 0);
    _radiusAxis = RadiusAxisView(context, props.radiusAxis, axisIndex: 0);
    addView(_angleAxis!);
    addView(_radiusAxis!);
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

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    double size = m.min(widthSpec.size, heightSpec.size);
    size = props.radius.last.convert(size) * 2;
    var spec = MeasureSpec.exactly(size);
    for (var child in children) {
      child.measure(spec, spec);
    }

    setMeasuredDimension(size, size);
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    center = Offset(props.center[0].convert(width), props.center[1].convert(height));
    contentBox = Rect.fromCircle(center: center, radius: width / 2);
    double size = measureWidth;
    double ir = props.radius.length > 1 ? props.radius.first.convert(size) : 0;
    double or = width / 2;

    var angleAttrs = AngleAxisAttrs(
      center,
      props.angleAxis.offsetAngle.toDouble(),
      [ir, or],
      scaleRatio: scaleX,
      scrollY: translationY,
      clockwise: props.angleAxis.clockwise,
    );
    var angleDim = const PolarAxisDim(false, 0);
    angleAxis.updateAttr(angleAttrs, collectChildDimData(angleDim));

    num angle = props.radiusAxis.offsetAngle;
    Offset so = ir <= 0 ? center : circlePoint(ir, angle, center);
    Offset eo = circlePoint(or, angle, center);

    var radiusAttrs = RadiusAxisAttrs(center, angle, contentBox, so, eo);
    var radiusDim = const PolarAxisDim(true, 0);
    radiusAxis.updateAttr(radiusAttrs, collectChildDimData(radiusDim));
    for (var c in children) {
      c.layout(0, 0, c.measureWidth, c.measureHeight);
    }
  }

  @override
  void onDraw(CCanvas canvas) {
    angleAxis.draw(canvas);
    radiusAxis.draw(canvas);
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
      return this.angleAxis.axisScale;
    }
    return radiusAxis.axisScale;
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
  PolarCoord(super.context, super.props);

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
