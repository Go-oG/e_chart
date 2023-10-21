import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/treemap/treemap_view.dart';
import 'package:flutter/material.dart';

///树图
class TreeMapSeries extends RectSeries {
  static final Command commandBack = Command(11);
  TreeMapData data;
  TreemapLayout layout = SquareLayout();

  //表示展示几层，从当前层次开始计算
  // 如果<=0 则展示全部
  int showDepth;
  Fun2<TreeMapData, AreaStyle?>? itemStyleFun;
  Fun2<TreeMapData, LineStyle?>? borderStyleFun;
  Fun2<TreeMapData, LabelStyle?>? labelStyleFun;

  ///标签文字对齐位置
  Fun2<TreeMapData, Alignment>? alignFun;

  Fun2<TreeMapData, num>? paddingInner;

  Fun2<TreeMapData, num>? paddingTop;

  Fun2<TreeMapData, num>? paddingRight;

  Fun2<TreeMapData, num>? paddingBottom;

  Fun2<TreeMapData, num>? paddingLeft;

  Fun3<TreeMapData, TreeMapData, int>? sortFun = (a, b) {
    return b.value.compareTo(a.value);
  };

  VoidFun1<TreeData>? onClick;

  TreeMapSeries(
    this.data, {
    this.labelStyleFun,
    this.itemStyleFun,
    this.borderStyleFun,
    TreemapLayout? layout,
    this.showDepth = 2,
    this.alignFun,
    this.sortFun,
    this.paddingInner,
    this.paddingLeft,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.onClick,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
  }) : super(gridIndex: -1, calendarIndex: -1, parallelIndex: -1, polarIndex: -1, radarIndex: -1) {
    if (layout != null) {
      this.layout = layout;
    }
  }

  void back() {
    value = commandBack;
  }

  @override
  ChartView? toView() {
    return TreeMapView(this);
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  int onAllocateStyleIndex(int start) {
    int c = 0;
    data.each((node, index, startNode) {
      node.styleIndex=index;
      c++;
      return false;
    });
    return c;
  }

  @override
  SeriesType get seriesType => SeriesType.treemap;

  LabelStyle getLabelStyle(Context context, TreeMapData node) {
    return labelStyleFun?.call(node) ?? LabelStyle.empty;
  }

  AreaStyle getAreaStyle(Context context, TreeMapData node) {
    if (itemStyleFun != null) {
      return itemStyleFun?.call(node) ?? AreaStyle.empty;
    }
    return context.option.theme.getAreaStyle(node.dataIndex).convert(node.status);
  }

  LineStyle getBorderStyle(Context context, TreeMapData node) {
    return borderStyleFun?.call(node) ?? LineStyle.empty;
  }

}
