import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/coord/grid/axis/base_grid_axis_impl.dart';
import 'package:flutter/material.dart';

class YAxisImpl extends BaseGridAxisImpl {
  YAxisImpl(super.coord, super.context, super.axis, {super.axisIndex});

  @override
  void doMeasure(double parentWidth, double parentHeight) {
    double length = parentHeight;
    double width = 0;
    AxisStyle axisStyle = axis.axisStyle;
    if (axisStyle.show) {
      var lineStyle = axisStyle.getAxisLineStyle(0, 1, getAxisTheme());
      width += (lineStyle?.width) ?? 0;
      num tickLength = 0;
      MainTick? tick = axisStyle.getMainTick(0, 1, getAxisTheme());
      if (tick != null && tick.show) {
        tickLength = tick.length;
      }
      MinorTick? minorTick = axisStyle.getMinorTick(0, 1, getAxisTheme());
      if (minorTick != null && minorTick.show) {
        tickLength = max([tickLength, minorTick.length]);
      }
      width += tickLength;
      var axisLabel = axisStyle.axisLabel;
      if (axisLabel.show) {
        double tmp = axisLabel.margin + axisLabel.padding + 0;
        var maxStr = getMaxStr(Direction.vertical);
        Size textSize = axisLabel.getLabelStyle(0, 1, getAxisTheme())?.measure(maxStr, maxWidth: 100) ?? Size.zero;
        tmp += textSize.width*0.5;
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
  void doLayout(LineAxisAttrs attrs, List<DynamicData> dataSet) {
    axisInfo.bound = attrs.rect;
    if (axis.position == Align2.end) {
      axisInfo.start = attrs.rect.bottomLeft;
      axisInfo.end = attrs.rect.topLeft;
    } else {
      axisInfo.start = attrs.rect.bottomRight;
      axisInfo.end = attrs.rect.topRight;
    }
    super.doLayout(attrs, dataSet);
  }

  @override
  void onScaleFactorChange(double factor) {
    double distance = axisInfo.bound.height * factor;
    if (distance.isNaN || distance.isInfinite) {
      throw ChartError('$runtimeType 长度未知：$distance');
    }
    scale = scale.copyWithRange([distance, 0]);

    //TODO 更新
    //  updateTickPosition();

    notifyLayoutUpdate();
  }

  @override
  List<Offset> dataToPoint(DynamicData data) {
    List<num> nl = scale.toRange(data.data);
    List<Offset> ol = [];
    for (var d in nl) {
      double y = d.toDouble();
      ol.add(Offset(0, y));
    }
    return ol;
  }
}
