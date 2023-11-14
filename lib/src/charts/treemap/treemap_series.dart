import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/treemap/layout/empty.dart';
import 'package:e_chart/src/charts/treemap/treemap_view.dart';
import 'package:flutter/material.dart';

///树图
class TreeMapSeries extends HierarchySeries<TreeMapData> {
  static final Command commandBack = Command(11);
  HierarchyLayout<TreeMapData, TreeMapSeries> layout = SquareLayout();
  bool round;

  //表示展示几层，从0开始计算
  // 如果<=0 则展示全部
  int initShowDepth;
  bool enableDrag;

  ///标签文字对齐位置
  Fun2<TreeMapData, Alignment>? labelAlignFun;
  Fun2<TreeMapData, num>? paddingInner;
  Fun2<TreeMapData, num>? paddingLeft;
  Fun2<TreeMapData, num>? paddingTop;
  Fun2<TreeMapData, num>? paddingRight;
  Fun2<TreeMapData, num>? paddingBottom;
  Fun3<TreeMapData, TreeMapData, int>? sortFun = (a, b) {
    return b.value.compareTo(a.value);
  };
  Offset labelPadding;

  TreeMapSeries(
    super.data, {
    HierarchyLayout<TreeMapData, TreeMapSeries>? layout,
    this.initShowDepth = 2,
    this.round = true,
    this.enableDrag = true,
    this.labelAlignFun,
    this.sortFun,
    this.paddingInner,
    this.paddingLeft,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.labelPadding = const Offset(2, 2),
    super.labelStyleFun,
    super.itemStyleFun,
    super.borderStyleFun,
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
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  SeriesType get seriesType => SeriesType.treemap;

  @override
  ChartView? toView() {
    return TreeMapView(this);
  }

  @override
  void dispose() {
    super.dispose();
    layout = EmptyTreemapLayout.layer;
    labelAlignFun = null;
    paddingInner = null;
    paddingTop = null;
    paddingRight = null;
    paddingBottom = null;
    paddingLeft = null;
    sortFun = null;
  }
}
