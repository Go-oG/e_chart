import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/coord/grid/axis/base_grid_axis_impl.dart';

///横向轴
class XAxisImpl extends BaseGridAxisImpl {
  XAxisImpl(super.axis);

  @override
  void measure(double parentWidth, double parentHeight) {
    AxisLine line = axis.axisLine;
    if (!line.show) {
      axisInfo.start = Offset.zero;
      axisInfo.end = Offset(parentWidth, 0);
      axisInfo.bound = Rect.fromLTWH(0, 0, parentWidth, 0);
      return;
    }
    double width = parentWidth;
    double height = line.style.width.toDouble();
    if (line.tick.show) {
      var mainTick = line.tick;
      if (mainTick.minorTick != null && mainTick.minorTick!.show) {
        height += max([mainTick.length, mainTick.minorTick!.length]);
      } else {
        height += mainTick.length;
      }
    }

    AxisLabel? axisLabel = line.label;
    if (axisLabel != null && axisLabel.show) {
      height += axisLabel.margin;
      var maxStr = getMaxStr(Direction.horizontal);
      Size textSize = axisLabel.labelStyle.measure(maxStr);
      height += textSize.height;
    }
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    axisInfo.start = rect.topLeft;
    axisInfo.end = rect.topRight;
    axisInfo.bound = rect;
  }

  @override
  void layout(LineProps layoutProps, List<DynamicData> dataSet) {
    Rect rect = layoutProps.rect;
    axisInfo.bound = rect;
    bool inside = axis.axisLine.tick.inside;
    if (inside) {
      axisInfo.start = rect.bottomLeft;
      axisInfo.end = rect.bottomRight;
    } else {
      axisInfo.start = rect.topLeft;
      axisInfo.end = rect.topRight;
    }
    super.layout(layoutProps, dataSet);
  }

  @override
  BaseScale buildScale(LineProps props, List<DynamicData> dataSet) {
    double distance = axisInfo.bound.width * scaleFactor;
    if (distance.isNaN || distance.isInfinite) {
      throw ChartError('$runtimeType 长度未知：$distance');
    }
    var s = axis.toScale([0, distance], dataSet, false);
    return s;
  }

  @override
  void onScaleFactorChange(double factor) {
    double distance = axisInfo.bound.width * factor;
    if (distance.isNaN || distance.isInfinite) {
      throw ChartError('$runtimeType 长度未知：$distance');
    }
    scale = scale.copyWithRange([0, distance]);
    updateTickPosition();
    notifyLayoutUpdate();
  }
}
