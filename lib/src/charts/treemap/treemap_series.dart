import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/treemap/treemap_view.dart';
import 'package:flutter/material.dart';

///树图
class TreeMapSeries extends RectSeries {
  static final Command commandBack = Command(11);
  TreeData data;
  TreemapLayout layout = SquareLayout();

  //表示展示几层，从当前层次开始计算
  // 如果<=0 则展示全部
  int showDepth;
  Fun2<TreeMapNode, AreaStyle?>? itemStyleFun;
  Fun2<TreeMapNode, LineStyle?>? borderStyleFun;
  Fun2<TreeMapNode, LabelStyle?>? labelStyleFun;

  ///标签文字对齐位置
  Fun2<TreeMapNode, Alignment>? alignFun;

  Fun2<TreeMapNode, num>? paddingInner;

  Fun2<TreeMapNode, num>? paddingTop;

  Fun2<TreeMapNode, num>? paddingRight;

  Fun2<TreeMapNode, num>? paddingBottom;

  Fun2<TreeMapNode, num>? paddingLeft;

  Fun3<TreeMapNode, TreeMapNode, int>? sortFun = (a, b) {
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
    super.z,
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
    List<TreeData> dl = [data];
    List<TreeData> next = [];
    while (dl.isNotEmpty) {
      each(dl, (p0, p1) {
        p0.styleIndex = c;
        c++;
      });
      next.addAll(dl);
      dl = next;
    }
    return c;
  }

  @override
  SeriesType get seriesType => SeriesType.treemap;

  LabelStyle getLabelStyle(Context context, TreeMapNode node) {
    return labelStyleFun?.call(node) ?? LabelStyle.empty;
  }

  AreaStyle getAreaStyle(Context context, TreeMapNode node) {
    if (itemStyleFun != null) {
      return itemStyleFun?.call(node) ?? AreaStyle.empty;
    }
    return context.option.theme.getAreaStyle(node.dataIndex).convert(node.status);
  }

  LineStyle getBorderStyle(Context context, TreeMapNode node) {
    return borderStyleFun?.call(node) ?? LineStyle.empty;
  }

}
