import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/grid/base_grid_series.dart';

class LineSeries extends BaseGridSeries<LineItemData, LineGroupData> {
  bool legendHoverLink; // 是否启用图例hover的联动高亮
  bool connectNulls; // 是否连接空数据
  bool realtimeSort; // 是否启用实时排序

  LinkageStyle linkageStyle;

  /// 主样式 对于绘制Line 使用其border 属性
  Fun3<LineItemData, LineGroupData, AreaStyle>? styleFun;

  /// 符号样式
  Fun3<LineItemData, LineGroupData, ChartSymbol>? symbolFun;

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
    this.legendHoverLink = true,
    this.connectNulls = true,
    super.direction,
    this.realtimeSort = false,
    this.linkageStyle = LinkageStyle.group,
    this.styleFun,
    this.stepLineFun,
    this.symbolFun,
    this.labelFun,
    this.labelStyleFun,
    this.labelAlignFun,
    this.markPointFun,
    this.markLineFun,
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
  }) : super(radarIndex: -1, calendarIndex: -1, parallelIndex: -1);
}
