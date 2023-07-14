import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///半径轴
class RadiusAxisImpl extends LineAxisImpl<RadiusAxis, RadiusProps> {
  RadiusAxisImpl(super.axis);

  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Rect coord) {
    AxisTheme theme = getAxisTheme();
    AxisStyle axisLine = axis.axisStyle;
    each(lineTickList, (tick, i) {
      LineStyle? style = axisLine.getSplitLineStyle(i, lineTickList.length, theme);
      if (style == null) {
        return;
      }
      Arc arc = Arc(
        innerRadius: 0,
        outRadius: tick.end.distance2(props.center),
        startAngle: props.offsetAngle,
        sweepAngle: 360,
        center: props.center,
      );
      style.drawPath(canvas, paint, arc.toPath(true));
    });
  }

  @override
  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Rect coord) {
    AxisTheme theme = getAxisTheme();
    AxisStyle axisLine = axis.axisStyle;
    each(lineTickList, (tick, i) {
      AreaStyle? style = axisLine.getSplitAreaStyle(i, lineTickList.length, theme);
      if (style == null) {
        return;
      }
      Arc arc = Arc(
        innerRadius: tick.start.distance2(props.center),
        outRadius: tick.end.distance2(props.center),
        startAngle: props.offsetAngle,
        sweepAngle: 360,
        center: props.center,
      );
      style.drawPath(canvas, paint, arc.toPath(true));
    });
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
