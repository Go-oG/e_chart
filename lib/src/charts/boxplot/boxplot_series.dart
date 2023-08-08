//盒须图
import 'package:e_chart/e_chart.dart';

class BoxplotSeries extends StackSeries<BoxplotData, BoxplotGroup> {
  /// Group组的间隔
  SNumber groupGap;

  ///Group组中柱状图之间的间隔
  SNumber columnGap;

  /// Column组里面的间隔
  num innerGap;

  BoxplotSeries(
    super.data, {
    this.columnGap = const SNumber.number(4),
    this.groupGap = const SNumber.number(4),
    this.innerGap = 0,
    super.direction,
    super.coordSystem,
    super.areaStyleFun,
    super.lineStyleFun,
    super.animation,
    super.polarIndex,
    super.gridIndex,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.z,
    super.clip,
  });

  @override
  AreaStyle? getAreaStyle(Context context, BoxplotData? data, BoxplotGroup group, int groupIndex, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group, status ?? {});
    }
    var chartTheme = context.option.theme;
    return AreaStyle(color: chartTheme.getColor(groupIndex)).convert(status);
  }

  @override
  LineStyle? getLineStyle(Context context, BoxplotData? data, BoxplotGroup group, int groupIndex, [Set<ViewState>? status]) {
    if (lineStyleFun != null) {
      return lineStyleFun?.call(data, group, status ?? {});
    }
    var barTheme = context.option.theme.boxplotTheme;
    return barTheme.getBorderStyle();
  }
}

class BoxplotGroup extends StackGroupData<BoxplotData> {
  SNumber? boxSize;
  SNumber? boxMaxSize;
  SNumber? boxMinSize;

  BoxplotGroup(
    super.data, {
    this.boxSize,
    this.boxMaxSize,
    this.boxMinSize = const SNumber(1, false),
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
  });

  @override
  set stackId(String? id) {
    throw ChartError("BoxplotGroup not support Stack Layout");
  }
}

class BoxplotData extends StackItemData {
  num max;
  num upAve4;
  num middle;
  num downAve4;
  num min;

  BoxplotData({
    required DynamicData x,
    required this.max,
    required this.upAve4,
    required this.middle,
    required this.downAve4,
    required this.min,
    super.label,
    super.id,
  }) : super(x, DynamicData(max));
}
