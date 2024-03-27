import 'dart:math';
import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///横向轴
class XAxisImpl extends BaseGridAxisImpl {
  XAxisImpl(super.direction, super.coord, super.context, super.axis, {super.axisIndex});

  @override
  void onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    if (!axis.show) {
      axisSize = 0;
      setMeasuredDimension(widthSpec.size, 0);
      return;
    }
    var lineHeight = axis.axisLine.getLength();
    var tickHeight = axis.axisTick.getMaxTickSize();

    double height = lineHeight + tickHeight;
    AxisLabel axisLabel = axis.axisLabel;
    if (axisLabel.show) {
      var labelHeight = axisLabel.margin + axisLabel.padding;
      labelHeight += axisLabel.getStyle(0, 1, axisTheme).measure(attrs.maxStr).height;
      if (axisLabel.inside == axis.axisTick.inside) {
        height += labelHeight;
      } else {
        height = max(height, labelHeight + lineHeight);
      }
    }
    axisSize = height;
    setMeasuredDimension(widthSpec.size, height);
  }

  @override
  List<Offset> dataToPoint(dynamic data) {
    checkDataType(data);
    List<num> nl = axisScale.toRange(data);
    List<Offset> ol = [];
    for (var d in nl) {
      ol.add(Offset(d.toDouble(), attrs.start.dy));
    }
    return ol;
  }

  @override
  dynamic pxToData(num position) {
    return axisScale.toData(position);
  }
}
