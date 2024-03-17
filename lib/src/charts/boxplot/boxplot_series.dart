//盒须图
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/boxplot/boxplot_view.dart';

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
  ChartView? toView(Context context) {
    return BoxPlotView(context, this);
  }

  @override
  SeriesType get seriesType => SeriesType.boxplot;

  @override
  AreaStyle getAreaStyle(Context context, covariant StackData<BoxplotData, BoxplotGroup> data, BoxplotGroup group) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group) ?? AreaStyle.empty;
    }
    var chartTheme = context.option.theme;
    return AreaStyle(color: chartTheme.getColor(group.styleIndex)).convert(data.status);
  }

  @override
  LineStyle getLineStyle(Context context, covariant StackData<BoxplotData, BoxplotGroup> data, BoxplotGroup group) {
    if (lineStyleFun != null) {
      return lineStyleFun?.call(data, group) ?? LineStyle.empty;
    }
    var barTheme = context.option.theme.boxplotTheme;
    return barTheme.getBorderStyle() ?? LineStyle.empty;
  }
}

class BoxplotGroup extends StackGroupData<BoxplotData, BoxplotGroup> {
  BoxplotGroup(
    super.data, {
    super.barMaxSize,
    super.barMinSize,
    super.barSize,
    super.domainAxis,
    super.valueAxis,
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
    super.name,
    super.id,
  }) : super(x, max);

  @override
  String toString() {
    return '$runtimeType x:$x name:$name id:$id\n'
        'max:${max.toStringAsFixed(2)} upAve4:${upAve4.toStringAsFixed(2)}\n'
        'middle:${middle.toStringAsFixed(2)} downAve4:${downAve4.toStringAsFixed(2)} '
        'min:${min.toStringAsFixed(2)}';
  }
}
