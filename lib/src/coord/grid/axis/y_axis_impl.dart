import 'package:e_chart/e_chart.dart';

import 'package:flutter/material.dart';

class YAxisImpl extends XAxisImpl {
  YAxisImpl(super.direction, super.context, super.coord, super.axis, {super.axisIndex});

  @override
  void doMeasure(double parentWidth, double parentHeight) {
    double length = parentHeight;
    double width = 0;
    if (axis.show) {
      var lineStyle = axis.getAxisLineStyle(0, 1, getAxisTheme());
      width += (lineStyle?.width) ?? 0;
      num tickLength = 0;
      MainTick? tick = axis.getMainTick(0, 1, getAxisTheme());
      if (tick != null && tick.show) {
        tickLength = tick.length;
      }
      MinorTick? minorTick = axis.getMinorTick(0, 1, getAxisTheme());
      if (minorTick != null && minorTick.show) {
        tickLength = max([tickLength, minorTick.length]);
      }
      width += tickLength;
      var axisLabel = axis.axisLabel;
      if (axisLabel.show) {
        double tmp = axisLabel.margin + axisLabel.padding + 0;
        var maxStr = getMaxStr(Direction.vertical);
        Size textSize = axisLabel.getLabelStyle(0, 1, getAxisTheme())?.measure(maxStr, maxWidth: 100) ?? Size.zero;
        tmp += textSize.width * 0.5;
        width += tmp;
      }
    }

    Rect rect = Rect.fromLTWH(0, 0, width, length);
    axisInfo.bound = rect;
    if (axis.position == Align2.end) {
      axisInfo.start = rect.bottomLeft;
      axisInfo.end = rect.topLeft;
    } else {
      axisInfo.start = rect.bottomRight;
      axisInfo.end = rect.topRight;
    }
  }

  @override
  List<Offset> dataToPoint(dynamic data) {
    checkDataType(data);
    List<num> nl = scale.toRange(data);
    List<Offset> ol = [];
    final double h = coord.contentBox.height;
    for (var d in nl) {
      double y = d.toDouble();
      double x = axis.position == Align2.end ? coord.contentBox.width : 0;
      ol.add(Offset(x, h - y));
    }
    return ol;
  }

  @override
  List<int> computeIndex(num distance, int tickCount, num interval) {
    Rect rect = coord.contentBox;
    int startIndex, endIndex;
    if (distance <= rect.height) {
      startIndex = 0;
      endIndex = tickCount;
    } else {
      double scroll = coord.scrollXOffset.abs();
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
    var diff = position - attrs.start.dy;
    return scale.toData(diff);
  }
}
