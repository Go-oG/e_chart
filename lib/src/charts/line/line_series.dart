import 'package:e_chart/e_chart.dart';

class LineSeries extends BaseGridSeries<LineItemData, LineGroupData> {
  bool connectNulls; // 是否连接空数据
  LinkageStyle linkageStyle;

  Fun3<LineGroupData, int, LineStyle?>? lineStyleFun;

  Fun3<LineGroupData, int, AreaStyle?>? areaStyleFun;

  /// 符号样式
  Fun3<LineItemData, LineGroupData, ChartSymbol?>? symbolFun;

  ///返回非空值表示是阶梯折线图
  Fun2<LineGroupData, StepType?>? stepLineFun;

  /// 标签转换
  Fun2<BarItemData, String>? labelFun;

  /// 标签样式
  Fun2<BarItemData, LabelStyle>? labelStyleFun;

  /// 标签对齐
  Fun2<BarItemData, Position2>? labelAlignFun;

  /// 标记点、线相关的
  Fun2<BarGroupData, MarkPoint>? markPointFun;

  Fun2<BarGroupData, MarkLine>? markLineFun;

  LineSeries(
    super.data, {
    this.connectNulls = false,
    this.linkageStyle = LinkageStyle.group,
    this.lineStyleFun,
    this.areaStyleFun,
    this.stepLineFun,
    this.symbolFun,
    this.labelFun,
    this.labelStyleFun,
    this.labelAlignFun,
    this.markPointFun,
    this.markLineFun,
    super.direction,
    super.realtimeSort,
    super.legendHoverLink,
    super.animatorStyle,
    super.selectedMode,
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    super.polarAxisIndex = -1,
    super.coordSystem = CoordSystem.grid,
    super.animation,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
    super.tooltip,
  });
}
