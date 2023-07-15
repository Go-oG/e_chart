import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/coord/grid/axis/base_grid_axis_impl.dart';

///横向轴
class XAxisImpl extends BaseGridAxisImpl {
  XAxisImpl(super.coord, super.context, super.axis, {super.axisIndex});

  @override
  void doMeasure(double parentWidth, double parentHeight) {
    AxisStyle axisStyle = axis.axisStyle;
    if (!axisStyle.show) {
      axisInfo.start = Offset.zero;
      axisInfo.end = Offset(parentWidth, 0);
      axisInfo.bound = Rect.fromLTWH(0, 0, parentWidth, 0);
      return;
    }
    double width = parentWidth;
    double height = (axisStyle.getAxisLineStyle(0, 1, getAxisTheme())?.width.toDouble()) ?? 0;
    MainTick? tick = axisStyle.getMainTick(0, 1, getAxisTheme());

    num tickHeight = (tick?.length ?? 0);
    MinorTick? minorTick = axisStyle.getMinorTick(0, 1, getAxisTheme());
    tickHeight = max([tickHeight, (minorTick?.length ?? 0)]);
    height += tickHeight;

    AxisLabel axisLabel = axisStyle.axisLabel;
    if (axisLabel.show) {
      height += axisLabel.margin;
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
  void doLayout(LineAxisAttrs attrs, List<DynamicData> dataSet) {
    Rect rect = attrs.rect;
    axisInfo.bound = rect;
    var axisLine = axis.axisStyle;
    bool inside = (axisLine.getMainTick(0, 1, getAxisTheme())?.inside) ?? true;
    if (axis.isCategoryAxis) {
      inside = false;
    }
    if (inside) {
      axisInfo.start = rect.bottomLeft;
      axisInfo.end = rect.bottomRight;
    } else {
      axisInfo.start = rect.topLeft;
      axisInfo.end = rect.topRight;
    }
    super.doLayout(attrs, dataSet);
  }

  @override
  BaseScale onBuildScale(LineAxisAttrs attrs, List<DynamicData> dataSet) {
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

    notifyLayoutUpdate();
  }

  @override
  List<Offset> dataToPoint(DynamicData data) {
    List<num> nl = scale.toRange(data.data);
    List<Offset> ol = [];
    for (var d in nl) {
      ol.add(Offset(d.toDouble(), 0));
    }
    return ol;
  }
}
