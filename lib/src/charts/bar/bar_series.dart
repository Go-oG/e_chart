import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/bar/bar_polar_view.dart';

import 'bar_grid_view.dart';

class BarSeries extends GridSeries<StackItemData, BarGroupData> {
  BarSeries(
    super.data, {
    super.corner,
    super.cornerFun,
    super.columnGap,
    super.groupGap,
    super.innerGap,
    super.labelAlignFun,
    super.groupStyleFun,
    super.areaStyleFun,
    super.lineStyleFun,
    super.labelFormatFun,
    super.labelStyleFun,
    super.markLine,
    super.markPoint,
    super.markPointFun,
    super.markLineFun,
    super.realtimeSort,
    super.sort,
    super.sortCount,
    super.legendHoverLink,
    super.direction,
    super.animatorStyle,
    super.selectedMode,
    super.gridIndex,
    super.polarIndex = -1,
    super.coordType = CoordType.grid,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
    super.tooltip,
    super.labelStyle,
    super.dynamicLabel,
    super.dynamicRange,
  });

  @override
  ChartView? toView() {
    if (coordType == CoordType.polar) {
      return BarPolarView(this);
    }
    return BarGridView(this);
  }

  @override
  SeriesType get seriesType => SeriesType.bar;
}
