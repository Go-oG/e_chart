//盒须图
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/boxplot/boxplot_chart.dart';

class BoxplotSeries extends GridSeries<BoxplotData, BoxplotGroup> {
  BoxplotSeries(
    super.data, {
    super.columnGap,
    super.groupGap,
    super.innerGap,
    super.direction,
    super.coordType,
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
    super.labelFormatFun,
    super.animatorStyle,
    super.labelStyle,
    super.labelStyleFun,
    super.markLine,
    super.markLineFun,
    super.markPoint,
    super.markPointFun,
    super.selectedMode,
  });

  @override
  ChartView? toView() {
    return BoxPlotView(this);
  }

  @override
  AreaStyle? getAreaStyle(Context context, BoxplotData? data, BoxplotGroup group, int styleIndex, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group, status ?? {});
    }
    var chartTheme = context.option.theme;
    return AreaStyle(color: chartTheme.getColor(styleIndex)).convert(status);
  }

  @override
  LineStyle? getLineStyle(Context context, BoxplotData? data, BoxplotGroup group, int styleIndex, [Set<ViewState>? status]) {
    if (lineStyleFun != null) {
      return lineStyleFun?.call(data, group, status ?? {});
    }
    var barTheme = context.option.theme.boxplotTheme;
    return barTheme.getBorderStyle();
  }
}

class BoxplotGroup extends StackGroupData<BoxplotData> {
  BoxplotGroup(
    super.data, {
    super.barMaxSize,
    super.barMinSize,
    super.barSize,
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    super.id,
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
    required dynamic x,
    required this.max,
    required this.upAve4,
    required this.middle,
    required this.downAve4,
    required this.min,
    super.label,
    super.id,
  }) : super(x, max);
}
