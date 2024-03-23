import 'package:e_chart/e_chart.dart';

import 'line_grid_view.dart';
import 'line_polar_view.dart';

class LineSeries extends GridSeries<StackItemData, LineGroupData> {
  bool connectNulls; // 是否连接空数据
  /// 符号样式
  Fun2<StackData<StackItemData, LineGroupData>, ChartSymbol?>? symbolFun;

  ///返回非空值表示是阶梯折线图
  Fun2<LineGroupData, LineType?>? stepLineFun;

  LineSeries(
    super.data, {
    super.labelStyle,
    this.connectNulls = false,
    super.lineStyleFun,
    super.areaStyleFun,
    this.stepLineFun,
    this.symbolFun,
    super.labelFormatFun,
    super.labelStyleFun,
    super.markLine,
    super.markPoint,
    super.markPointFun,
    super.markLineFun,
    super.direction,
    super.realtimeSort,
    super.legendHoverLink,
    super.animatorStyle,
    super.selectedMode,
    super.gridIndex,
    super.polarIndex = -1,
    super.coordType = CoordType.grid,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.tooltip,
    super.corner,
    super.cornerFun,
    super.dynamicLabel,
    super.dynamicRange,
    super.sort,
    super.sortCount,
    super.stackIsPercent,
    super.labelAlignFun,
    super.groupStyleFun,
  }) : super(groupGap: SNumber.zero, columnGap: SNumber.zero);

  @override
  ChartView? toView(Context context) {
    var type = coordType;
    if (type != null && type.isPolar()) {
      return LinePolarView(context, this);
    } else {
      return LineGridView(context, this);
    }
  }

  @override
  SeriesType get seriesType => SeriesType.line;

  ChartSymbol? getSymbol(Context context, StackData<StackItemData, LineGroupData> data) {
    if (symbolFun != null) {
      return symbolFun?.call(data);
    }
    if (context.option.theme.lineTheme.showSymbol) {
      return context.option.theme.lineTheme.symbol;
    }
    return null;
  }

  LineType? getLineType(Context context, LineGroupData group) => stepLineFun?.call(group);
}
