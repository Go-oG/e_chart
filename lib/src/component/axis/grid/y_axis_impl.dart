import 'package:e_chart/e_chart.dart';

import 'package:flutter/material.dart';

class YAxisImpl extends XAxisImpl {
  YAxisImpl(super.direction, super.context, super.axis, super.attrs);

  @override
  void onMeasure(double parentWidth, double parentHeight) {
    axisInfo.reset();
    if (!axis.show) {
      axisInfo.start = axisInfo.end = Offset.zero;
      axisInfo.height = parentHeight;
      axisInfo.width = 0;
      return;
    }

    var lineWidth = axis.axisLine.getLength();
    var tickWidth = axis.axisTick.getMaxTickSize();

    double width = lineWidth + tickWidth;
    AxisLabel axisLabel = axis.axisLabel;
    if (axisLabel.show) {
      var labelWidth = axisLabel.margin + axisLabel.padding;
      var maxStr = attrs.maxStr;
      labelWidth += axisLabel.getStyle(0, 1, getAxisTheme()).measure(maxStr).width;
      if (axisLabel.inside == axis.axisTick.inside) {
        width += labelWidth;
      } else {
        width = max<double>([width, labelWidth + lineWidth]).toDouble();
      }
    }
    axisInfo.width = width;
    axisInfo.height = parentHeight;
  }

  @override
  List<Offset> dataToPoint(dynamic data) {
    checkDataType(data);
    List<num> nl = scale.toRange(data);
    List<Offset> ol = [];
    final double h = attrs.contentBox.height;
    for (var d in nl) {
      double y = d.toDouble();
      double x = axis.position == Align2.end ? attrs.contentBox.width : 0;
      ol.add(Offset(x, h - y));
    }
    return ol;
  }

  @override
  List<int> computeRangeIndex(num distance, int tickCount, num interval) {
    Rect rect = attrs.contentBox;
    int startIndex, endIndex;
    if (distance <= rect.height) {
      startIndex = 0;
      endIndex = tickCount;
    } else {
      double scroll = attrs.scrollX.abs();
      startIndex = scroll ~/ interval - 2;
      if (startIndex < 0) {
        startIndex = 0;
      }
      endIndex = (scroll + rect.height) ~/ interval + 2;
      if (endIndex > tickCount) {
        endIndex = tickCount;
      }
    }
    return [startIndex, endIndex];
  }

  @override
  dynamic pxToData(num position) {
    return scale.toData(position);
  }
}
