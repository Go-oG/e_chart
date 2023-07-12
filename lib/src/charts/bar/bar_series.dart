import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/grid/base_grid_series.dart';

class BarSeries extends BaseGridSeries<BarItemData,BarGroupData> {
  SNumber corner; // 圆角只有在 bar时才有效
  SNumber groupGap; // Group组的间隔
  SNumber columnGap; //Group组中柱状图之间的间隔
  num innerGap; // Column组里面的间隔

  bool legendHoverLink; // 是否启用图例hover的联动高亮
  bool realtimeSort; // 是否启用实时排序
  AnimatorStyle animatorStyle;
  LinkageStyle linkageStyle;

  /// 主样式 对于绘制Line 使用其border 属性
  Fun3<BarItemData, BarGroupData, AreaStyle>? itemStyleFun;

  ///绘制对齐
  Fun2<BarGroupData, Align2>? alignFun;

  /// 背景样式
  Fun2<BarItemData, AreaStyle>? backgroundStyleFun;

  /// 标签转换
  Fun2<BarItemData, String>? labelFun;

  /// 标签样式
  Fun2<BarItemData, LabelStyle>? labelStyleFun;

  /// 标签对齐
  Fun2<BarItemData, Position2>? labelAlignFun;

  /// 标记点、线相关的
  Fun2<BarGroupData, MarkPoint>? markPointFun;

  Fun2<BarGroupData, MarkLine>? markLineFun;

  BarSeries(
    super.data, {
    this.legendHoverLink = true,
    super.direction,
    this.corner = SNumber.zero,
    this.columnGap =const SNumber.number(4),
    this.groupGap = const SNumber.number(4),
    this.innerGap = 0,
    this.realtimeSort = false,
    this.animatorStyle = AnimatorStyle.expand,
    this.linkageStyle = LinkageStyle.group,
    this.itemStyleFun,
    this.alignFun,
    this.labelFun,
    this.labelStyleFun,
    this.labelAlignFun,
    this.backgroundStyleFun,
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

///动画样式
enum AnimatorStyle { expand, selfExpand }

/// 标识一个Group的手势联动策略
enum LinkageStyle {
  none,
  single, // 只有自身变化
  group, // 联动Group
}
