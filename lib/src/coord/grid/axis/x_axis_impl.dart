import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/coord/grid/axis/base_grid_axis_impl.dart';
import 'package:flutter/material.dart';

///横向轴
class XAxisImpl extends BaseGridAxisImpl {
  XAxisImpl(super.direction, super.coord, super.context, super.axis, {super.axisIndex});

  @override
  void doMeasure(double parentWidth, double parentHeight) {

    if (!axis.show) {
      axisInfo.start = axis.position == Align2.start ? const Offset(0, 0) : Offset(0, parentHeight);
      axisInfo.end = Offset(parentWidth, 0);
      axisInfo.bound = Rect.fromLTWH(0, 0, parentWidth, 0);
      return;
    }
    double width = parentWidth;
    double height = (axis.getAxisLineStyle(0, 1, getAxisTheme())?.width.toDouble()) ?? 0;
    MainTick? tick = axis.getMainTick(0, 1, getAxisTheme());
    num tickHeight = 0;
    if (tick != null && tick.show) {
      tickHeight = tick.length;
    }
    MinorTick? minorTick = axis.getMinorTick(0, 1, getAxisTheme());
    if (minorTick != null && minorTick.show) {
      tickHeight = max([tickHeight, minorTick.length]);
    }
    height += tickHeight;

    AxisLabel axisLabel = axis.axisLabel;
    if (axisLabel.show) {
      height += axisLabel.margin + axisLabel.padding;
      var maxStr = getMaxStr(Direction.horizontal);
      Size textSize = axisLabel.getLabelStyle(0, 1, getAxisTheme())?.measure(maxStr) ?? Size.zero;
      height += textSize.height;
    }
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    axisInfo.start = rect.topLeft;
    axisInfo.end = rect.topRight;
    axisInfo.bound = rect;
  }

  @override
  List<Offset> dataToPoint(DynamicData data) {
    List<num> nl = scale.toRange(data.data);
    List<Offset> ol = [];
    for (var d in nl) {
      ol.add(Offset(d.toDouble(), attrs.start.dy));
    }
    return ol;
  }

}
