import 'dart:math';

import 'package:flutter/material.dart';

import '../../component/axis/impl/line_axis_impl.dart';
import '../../model/dynamic_data.dart';
import '../../style/line_style.dart';
import 'axis_radius.dart';

///半径轴
class RadiusAxisImpl extends LineAxisImpl<RadiusAxis, RadiusProps> {
  RadiusAxisImpl(super.axis);

  @override
  void draw(Canvas canvas, Paint paint) {
    drawInnerCircle(canvas, paint);
    super.draw(canvas, paint);
  }

  void drawInnerCircle(Canvas canvas, Paint paint) {
    if (axis.axisStyleFun == null) {
      return;
    }
    int circleCount = scale.tickCount;
    circleCount=max(circleCount, 2);
    double interval = props.distance / (circleCount-1);
    for (int i = 1; i < circleCount; i++) {
      LineStyle? style = axis.axisStyleFun!.call(i - 1, circleCount);
      style.drawArc(canvas, paint, i * interval, props.offsetAngle, 360, props.center);
    }
  }

  List<num> dataToRadius(DynamicData data) {
    return scale.toRange(data.data);
  }
}

class RadiusProps extends LineProps {
  final Offset center;
  final num offsetAngle;

  RadiusProps(this.center, this.offsetAngle, super.rect, super.start, super.end);
}
