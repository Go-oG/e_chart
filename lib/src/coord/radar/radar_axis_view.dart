import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class RadarAxisView extends LineAxisView<RadarAxis, LineAxisAttrs> {
  RadarAxisView(super.context, super.axis, {super.axisIndex});

  double dataToRadius(num data) {
    return axisScale.toRange(data)[0].toDouble();
  }

  @override
  List<Drawable>? onLayoutSplitArea(LineAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    var splitArea = axis.splitArea;
    if (!splitArea.show) {
      return null;
    }
    List<Drawable> list = [];
    int tickCount = scale.tickCount;
    double interval = scale.tickInterval;
    var angle = axisAngle;
    for (int i = 0; i < tickCount - 1; i++) {
      var style = splitArea.getStyle(i, tickCount - 1, axisTheme);

      var arc = Arc(
          center: attrs.start,
          innerRadius: interval * i,
          outRadius: interval * (i + 1),
          sweepAngle: 360,
          startAngle: angle);

      list.add(SplitAreaDrawable([], arc.toPath(), style));
    }
    return list;
  }

  @override
  List<Drawable>? onLayoutSplitLine(LineAxisAttrs attrs, BaseScale<dynamic, num> scale) {
    var splitLine = axis.splitLine;
    if (!splitLine.show) {
      return null;
    }
    List<Drawable> list = [];
    int tickCount = scale.tickCount;
    double interval = scale.tickInterval;
    var angle = axisAngle;
    for (int i = 1; i < tickCount - 1; i++) {
      var style = splitLine.getStyle([], i, tickCount - 1, axisTheme);
      list.add(AxisCurveDrawable([], i, tickCount - 1, attrs.start, interval * i, angle, 360, style));
    }
    return list;
  }

  @override
  LineAxisAttrs onBuildDefaultAttrs() => LineAxisAttrs(Rect.zero, Offset.zero, Offset.zero);
}
