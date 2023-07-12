import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/coord/grid/axis/base_grid_axis_impl.dart';

class YAxisImpl extends BaseGridAxisImpl {
  YAxisImpl(super.coord, super.axis, {super.axisIndex});

  @override
  void measure(double parentWidth, double parentHeight) {
    double length = parentHeight;
    double width = 0;
    AxisStyle axisStyle = axis.axisStyle;
    if (axisStyle.show) {
      var lineStyle = axisStyle.getAxisLineStyle(0, 1, getAxisTheme());
      width += (lineStyle?.width) ?? 0;

      MainTick? tick = axisStyle.getMainTick(0, 1, getAxisTheme());
      num tw = (tick?.length ?? 0);

      MinorTick? minorTick = axisStyle.getMinorTick(0, 1, getAxisTheme());
      tw = max([tw, (minorTick?.length ?? 0)]);
      width += tw;
    }

    AxisLabel axisLabel = axisStyle.axisLabel;
    if (axisLabel.show) {
      width += axisLabel.margin + axisLabel.padding;
      var maxStr = getMaxStr(Direction.vertical);
      Size textSize = axisLabel.getLabelStyle(0, 1, getAxisTheme())?.measure(maxStr) ?? Size.zero;
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
    bool inside = (axis.axisStyle.getMainTick(0, 1, getAxisTheme())?.inside) ?? true;
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
