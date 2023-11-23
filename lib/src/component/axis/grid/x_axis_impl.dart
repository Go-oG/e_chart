import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///横向轴
class XAxisImpl extends BaseGridAxisImpl {
  XAxisImpl(super.direction, super.coord, super.context, super.axis, super.attrs);

  @override
  void onMeasure(double parentWidth, double parentHeight) {
    if (!axis.show) {
      axisSize = 0;
      return;
    }
    var lineHeight = axis.axisLine.getLength();
    var tickHeight = axis.axisTick.getMaxTickSize();

    double height = lineHeight + tickHeight;
    AxisLabel axisLabel = axis.axisLabel;
    if (axisLabel.show) {
      var labelHeight = axisLabel.margin + axisLabel.padding;
      labelHeight += axisLabel.getStyle(0, 1, getAxisTheme()).measure(attrs.maxStr).height;
      if (axisLabel.inside == axis.axisTick.inside) {
        height += labelHeight;
      } else {
        height = max<double>([height, labelHeight + lineHeight]).toDouble();
      }
    }
    axisSize=height;
  }

  @override
  List<Offset> dataToPoint(dynamic data) {
    checkDataType(data);
    List<num> nl = scale.toRange(data);
    List<Offset> ol = [];
    for (var d in nl) {
      ol.add(Offset(d.toDouble(), attrs.start.dy));
    }
    return ol;
  }

  @override
  dynamic pxToData(num position) {
    return scale.toData(position);
  }
}
