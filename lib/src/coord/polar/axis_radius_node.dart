import 'package:flutter/material.dart';

import '../../component/axis/impl/line_axis_impl.dart';
import '../../model/dynamic_data.dart';
import '../../style/line_style.dart';
import 'axis_radius.dart';

///半径轴
class RadiusAxisImpl extends LineAxisImpl<RadiusAxis> {
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
    if (circleCount <= 0) {
      circleCount = 1;
    }
    double interval = props.distance / circleCount;
    for (int i = 1; i < circleCount; i++) {
      LineStyle? style = axis.axisStyleFun!.call(i - 1, circleCount, null);
      style?.drawArc(canvas, paint, i * interval, 0, 360);
    }
  }

  num dataToRadius(DynamicData data) {
    return scale.rangeValue(data);
  }
}
