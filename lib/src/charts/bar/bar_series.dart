import 'package:e_chart/e_chart.dart';

class BarSeries extends ChartSeries {
  List<GridGroupData> data;
  Direction direction; // 布局方向
  SNumber corner; // 圆角只有在 bar时才有效
  SNumber groupGap; // Group组的间隔
  SNumber columnGap; //Group组中柱状图之间的间隔
  num innerGap; // Column组里面的间隔

  bool legendHoverLink; // 是否启用图例hover的联动高亮
  bool connectNulls; // 是否连接空数据
  bool realtimeSort; // 是否启用实时排序
  AnimatorStyle animatorStyle;
  LinkageStyle linkageStyle;

  /// 主样式 对于绘制Line 使用其border 属性
  Fun3<GridItemData, GridGroupData, AreaStyle>? itemStyleFun;

  /// 只会在绘制直线组时调用该方法，返回true 表示是阶梯折线图
  Fun2<GridGroupData, bool>? stepLineFun;

  ///绘制对齐
  Fun2<GridGroupData, Align2>? alignFun;

  /// 符号样式
  Fun2<GridItemData, ChartSymbol>? symbolFun;

  /// 背景样式(只在某些形状下有效)
  Fun2<GridItemData, AreaStyle>? backgroundStyleFun;

  /// 标签转换
  Fun2<GridItemData, String>? labelFun;

  /// 标签样式
  Fun2<GridItemData, LabelStyle>? labelStyleFun;

  /// 标签对齐
  Fun2<GridItemData, Position2>? labelAlignFun;

  /// 标记点、线相关的
  Fun2<GridGroupData, MarkPoint>? markPointFun;

  Fun2<GridGroupData, MarkLine>? markLineFun;

  BarSeries(
    this.data, {
    this.legendHoverLink = true,
    this.connectNulls = true,
    this.direction = Direction.vertical,
    this.corner = SNumber.zero,
    this.columnGap =const SNumber.number(4),
    this.groupGap = const SNumber.number(4),
    this.innerGap = 0,
    this.realtimeSort = false,
    this.animatorStyle = AnimatorStyle.expand,
    this.linkageStyle = LinkageStyle.group,
    this.itemStyleFun,
    this.stepLineFun,
    this.alignFun,
    this.symbolFun,
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
