import 'package:e_chart/e_chart.dart';

import 'BarGridView.dart';
import 'bar_chart.dart';

class BarSeries extends StackSeries<StackItemData, BarGroupData> {
  BarSeries(
    super.data, {
    super.corner,
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
    super.legendHoverLink,
    super.direction,
    super.animatorStyle,
    super.selectedMode,
    super.gridIndex,
    super.polarIndex = -1,
    super.coordSystem = CoordSystem.grid,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
    super.tooltip,
  });

  @override
  ChartView? toView() {
    if (coordSystem != CoordSystem.polar) {
      return BarGridView(this);
    }
    return BarView(this);
  }
}
