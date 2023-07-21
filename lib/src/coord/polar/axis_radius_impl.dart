import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///半径轴
class RadiusAxisImpl extends LineAxisImpl<RadiusAxis, RadiusAxisAttrs, PolarCoord> {
  RadiusAxisImpl(super.context, super.coord, super.axis);

  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint,  Offset scroll) {
    AxisTheme theme = getAxisTheme();
    AxisStyle axisLine = axis.axisStyle;
    int c = layoutResult.split.length;
    each(layoutResult.split, (split, i) {
      LineStyle? style = axisLine.getSplitLineStyle(i, c, theme);
      if (style == null) {
        return;
      }

      Arc arc = Arc(
        innerRadius: 0,
        outRadius: split.start.distance2(split.center),
        startAngle: attrs.offsetAngle,
        sweepAngle: 360,
        center: attrs.center,
      );
      style.drawPath(canvas, paint, arc.toPath(true));
    });
  }

  @override
  void onDrawAxisSplitArea(Canvas canvas, Paint paint,  Offset scroll) {
    AxisTheme theme = getAxisTheme();
    AxisStyle axisLine = axis.axisStyle;
    int c = layoutResult.split.length;
    each(layoutResult.split, (split, i) {
      AreaStyle? style = axisLine.getSplitAreaStyle(i, c, theme);
      if (style == null) {
        return;
      }
      Arc arc = Arc(
        innerRadius: split.start.distance2(split.center),
        outRadius: split.end.distance2(split.center),
        startAngle: attrs.offsetAngle,
        sweepAngle: 360,
        center: attrs.center,
      );
      style.drawPath(canvas, paint, arc.toPath(true));
    });
  }

  List<num> dataToRadius(DynamicData data) {
    return scale.toRange(data.data);
  }
}

class RadiusAxisAttrs extends LineAxisAttrs {
  final Offset center;
  final num offsetAngle;

  RadiusAxisAttrs(
    this.center,
    this.offsetAngle,
    super.scaleRatio,
    super.scroll,
    super.rect,
    super.start,
    super.end,
  );

  @override
  RadiusAxisAttrs copyWith({
    double? scaleRatio,
    double? scroll,
    Rect? rect,
    Offset? start,
    Offset? end,
    Offset? center,
    num? offsetAngle,
  }) {
    return RadiusAxisAttrs(
      center ?? this.center,
      offsetAngle ?? this.offsetAngle,
      scaleRatio ?? this.scaleRatio,
      scroll ?? this.scroll,
      rect ?? this.rect,
      start ?? this.start,
      end ?? this.end,
    );
  }
}
