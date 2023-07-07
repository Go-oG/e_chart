import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/coord/grid/axis/base_grid_axis_impl.dart';

class YAxisImpl extends BaseGridAxisImpl {
  YAxisImpl(super.axis);

  @override
  void measure(double parentWidth, double parentHeight) {
    double length = parentHeight;
    double width = 0;
    AxisStyle line = axis.axisLine;
    if (line.show) {
      var lineStyle = line.getAxisLineStyle(0, 1, getAxisTheme());
      width += (lineStyle?.width) ?? 0;

      MainTick tick = line.getMainTick(0, 1, getAxisTheme()) ?? MainTick();
      if (tick.show) {
        num l1 = tick.length;
        num l2 = tick.minorTick?.length ?? 0;
        if (!(tick.minorTick?.show ?? false)) {
          l2 = 0;
        }
        width += max([l1, l2]);
      }
    }

    AxisLabel? axisLabel = line.label;
    if (axisLabel != null && axisLabel.show) {
      width += axisLabel.margin;
      var maxStr = getMaxStr(Direction.vertical);
      Size textSize = axisLabel.labelStyle.measure(maxStr);
      width += textSize.width;
    }
    Rect rect = Rect.fromLTWH(0, 0, width, length);
    axisInfo.bound = rect;
    axisInfo.start = rect.topLeft;
    axisInfo.end = rect.topRight;
  }

  @override
  void layout(LineProps layoutProps, List<DynamicData> dataSet) {
    axisInfo.bound = layoutProps.rect;
    bool inside = (axis.axisLine.getMainTick(0, 1, getAxisTheme())?.inside) ?? true;
    if (inside) {
      axisInfo.start = layoutProps.rect.topLeft;
      axisInfo.end = layoutProps.rect.bottomLeft;
    } else {
      axisInfo.start = layoutProps.rect.topRight;
      axisInfo.end = layoutProps.rect.bottomRight;
    }
    super.layout(layoutProps, dataSet);
  }

  @override
  BaseScale buildScale(LineProps props, List<DynamicData> dataSet) {
    double distance = axisInfo.bound.height * scaleFactor;
    if (distance.isNaN || distance.isInfinite) {
      throw ChartError('$runtimeType 长度异常');
    }
    return axis.toScale([distance, 0], dataSet, false);
  }

  @override
  void onScaleFactorChange(double factor) {
    double distance = axisInfo.bound.height * factor;
    if (distance.isNaN || distance.isInfinite) {
      throw ChartError('$runtimeType 长度未知：$distance');
    }
    scale = scale.copyWithRange([distance, 0]);
    updateTickPosition();
    notifyLayoutUpdate();
  }
}
