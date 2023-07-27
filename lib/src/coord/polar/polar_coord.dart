import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///用于实现极坐标系
///支持 柱状图 折线图 散点图
class PolarCoordImpl extends PolarCoord {
  late AngleAxisImpl<PolarCoord> _angleAxis;
  late RadiusAxisImpl _radiusAxis;
  Offset center = Offset.zero;

  PolarCoordImpl(super.props);

  @override
  void onCreate() {
    super.onCreate();
    _angleAxis = AngleAxisImpl(context, this, props.angleAxis);
    _radiusAxis = RadiusAxisImpl(context, this, props.radiusAxis);
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
    _angleAxis.doMeasure(size, size);
    _radiusAxis.doMeasure(size, size);
    return Size.square(size);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    center = Offset(props.center[0].convert(width), props.center[1].convert(height));
    contentBox = Rect.fromCircle(center: center, radius: width / 2);
    double size = m.min(measureSize.width, measureSize.height);
    double ir = props.radius.length > 1 ? props.radius.first.convert(size) : 0;
    double or = width / 2;

    AngleAxis angleAxis = props.angleAxis;
    var angleAttrs = AngleAxisAttrs(
      center,
      angleAxis.offsetAngle.toDouble(),
      [ir, or],
      scaleYFactor,
      scrollYOffset,
      clockwise: angleAxis.clockwise,
    );
    _angleAxis.doLayout(angleAttrs, _getAngleDataSet());

    num angle = props.radiusAxis.offsetAngle;
    Offset so = ir <= 0 ? center : circlePoint(ir, angle, center);
    Offset eo = circlePoint(or, angle, center);

    var radiusAttrs = RadiusAxisAttrs(center, angle, 1, 1, contentBox, so, eo);
    _radiusAxis.doLayout(radiusAttrs, _getRadiusDataSet());

    for (var c in children) {
      c.layout(0, 0, width, height);
    }
  }

  List<DynamicData> _getAngleDataSet() {
    List<DynamicData> list = [];
    for (var child in children) {
      if (child is! PolarChild) {
        continue;
      }
      PolarChild c = child as PolarChild;
      list.addAll(c.getAngleDataSet());
    }
    return list;
  }

  List<DynamicData> _getRadiusDataSet() {
    List<DynamicData> list = [];
    for (var child in children) {
      if (child is! PolarChild) {
        continue;
      }
      PolarChild c = child as PolarChild;
      list.addAll(c.getRadiusDataSet());
    }
    return list;
  }

  @override
  void onDraw(Canvas canvas) {
    _angleAxis.draw(canvas, mPaint, selfBoxBound);
    _radiusAxis.draw(canvas, mPaint, selfBoxBound);
  }

  @override
  PolarPosition dataToPosition(DynamicData radiusData, DynamicData angleData) {
    List<num> angles = _angleAxis.dataToAngle(angleData);
    List<num> r = _radiusAxis.dataToRadius(radiusData);
    if (props.radius.length > 1) {
      double ir = _radiusAxis.attrs.start.distance2(_radiusAxis.attrs.center);
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
      return _angleAxis.scale;
    }
    return _radiusAxis.scale;
  }

  @override
  num getStartAngle() {
    return _angleAxis.axis.offsetAngle;
  }

  @override
  List<double> getRadius() {
    return _angleAxis.attrs.radius;
  }
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

  Offset get position{
    return circlePoint(radius.last, angle.last,center);
  }
}

abstract class PolarCoord extends CircleCoord<PolarConfig> {
  PolarCoord(super.props);

  PolarPosition dataToPosition(DynamicData radiusData, DynamicData angleData);

  Offset getCenter();

  List<double> getRadius();

  num getStartAngle();

  BaseScale getScale(bool angleAxis);
}
