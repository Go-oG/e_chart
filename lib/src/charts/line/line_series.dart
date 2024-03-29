import 'package:e_chart/e_chart.dart';

class LineSeries extends StackSeries<StackItemData, LineGroupData> {
  bool connectNulls; // 是否连接空数据

  /// 符号样式
  Fun4<StackItemData, LineGroupData, Set<ViewState>, ChartSymbol?>? symbolFun;

  ///返回非空值表示是阶梯折线图
  Fun2<LineGroupData, StepType?>? stepLineFun;

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
    super.coordSystem = CoordSystem.grid,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
    super.tooltip,
  });
}
