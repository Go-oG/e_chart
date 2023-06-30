import 'dart:math' as m;
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class PolarCoord extends CircleCoord<PolarConfig> {
  PolarCoord(super.props);

  PolarPosition dataToPosition(DynamicData radiusData, DynamicData angleData);

  Offset getCenter();
}

class PolarPosition {
  final Offset center;

  ///当radius是一个范围时起长度为2 否则为1
  final List<num> radius;

  ///当angle是一个范围时起长度为2 否则为1
  final List<num> angle;

  PolarPosition(this.center, this.radius, this.angle);
}

///用于实现极坐标系
///支持 柱状图 折线图 散点图
class PolarCoordImpl extends PolarCoord {
  late final AngleAxisImpl _angleAxis;
  late final RadiusAxisImpl _radiusAxis;

  Offset center = Offset.zero;

  PolarCoordImpl(super.props) {
    _angleAxis = AngleAxisImpl(props.angleAxis);
    _radiusAxis = RadiusAxisImpl(props.radiusAxis);
  }

  @override
  void onHoverStart(Offset offset) {}

  @override
  void onHoverMove(Offset offset, Offset last) {}


  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    double size = m.min(parentWidth, parentHeight);
    size = props.radius.convert(size) * 2;
    return Size.square(size);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    center = Offset(props.center[0].convert(width), props.center[1].convert(height));

    double r = width / 2;
    AngleAxis angleAxis = props.angleAxis;
    ArcProps angleProps = ArcProps(
      center,
      angleAxis.offsetAngle.toDouble(),
      r + angleAxis.radiusOffset,
      clockwise: angleAxis.clockwise,
    );
    RadiusProps radiusProps = RadiusProps(
      center,
      angleAxis.offsetAngle,
      boxBounds,
      center,
      circlePoint(r, props.radiusAxis.offsetAngle, center),
    );
    _angleAxis.layout(angleProps, _getAngleDataSet());
    _radiusAxis.layout(radiusProps, _getRadiusDataSet());

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
      list.addAll(c.angleDataSet);
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
      list.addAll(c.radiusDataSet);
    }
    return list;
  }

  @override
  void onDraw(Canvas canvas) {
    _angleAxis.draw(canvas, mPaint);
    _radiusAxis.draw(canvas, mPaint);
  }

  @override
  PolarPosition dataToPosition(DynamicData radiusData, DynamicData angleData) {
    List<num> angles = _angleAxis.dataToAngle(angleData);
    List<num> r = _radiusAxis.dataToRadius(radiusData);
    return PolarPosition(center, r, angles);
  }

  @override
  Offset getCenter() => center;
}
