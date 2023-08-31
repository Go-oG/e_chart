import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/sankey/sankey_view.dart';
import 'package:flutter/material.dart';

class SankeySeries extends RectSeries {
  SankeyData data;
  double nodeWidth;
  double gap;
  int iterationCount;
  SankeyAlign align;
  NodeSort? nodeSort;
  LinkSort? linkSort;
  Direction direction;
  bool smooth;
  Fun4<BaseItemData, int, Set<ViewState>, AreaStyle?>? areaStyleFun;

  Fun4<BaseItemData, int, Set<ViewState>, LineStyle?>? borderStyleFun;

  Fun4<BaseItemData, int, Set<ViewState>, LabelStyle?>? labelStyleFun;

  Fun7<BaseItemData, int, BaseItemData, int, int, Set<ViewState>, AreaStyle>? linkStyleFun;
  Fun7<BaseItemData, int, BaseItemData, int, int, Set<ViewState>, LineStyle>? linkBorderStyleFun;
  Fun7<BaseItemData, int, BaseItemData, int, int, Set<ViewState>, LabelStyle>? linkLabelStyleFun;

  SankeySeries({
    required this.data,
    this.nodeWidth = 32,
    this.gap = 8,
    this.iterationCount = 6,
    this.align = const JustifyAlign(),
    this.direction = Direction.horizontal,
    this.nodeSort,
    this.linkSort,
    this.areaStyleFun,
    this.linkStyleFun,
    this.smooth = true,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.animation = const AnimationAttrs(duration: Duration(seconds: 2), curve: Curves.ease),
    super.clip,
    super.z,
  }) : super(gridIndex: -1, polarIndex: -1, radarIndex: -1, calendarIndex: -1, parallelIndex: -1);

  @override
  ChartView? toView() {
    return SankeyView(this);
  }

  AreaStyle? getItemStyle(Context context, BaseItemData data, int index, Set<ViewState> status) {
    var fun = areaStyleFun;
    if (fun != null) {
      return fun.call(data, index, status);
    }
    return context.option.theme.getAreaStyle(index).convert(status);
  }

  LineStyle? getBorderStyle(Context context, BaseItemData data, int index, Set<ViewState> status) {
    var fun = borderStyleFun;
    if (fun != null) {
      return fun.call(data, index, status);
    }
    return context.option.theme.sankeyTheme.getStyle()?.convert(status);
  }

  LabelStyle? getLabelStyle(Context context, BaseItemData data, int index, Set<ViewState> status) {
    var fun = labelStyleFun;
    if (fun != null) {
      return fun.call(data, index, status);
    }
    return context.option.theme.getLabelStyle();
  }

  AreaStyle getLinkStyle(
    Context context,
    BaseItemData sourceData,
    int sourceIndex,
    BaseItemData targetData,
    int targetIndex,
    int index,
    Set<ViewState> status,
  ) {
    var fun = linkStyleFun;
    if (fun != null) {
      return fun.call(sourceData, sourceIndex, targetData, targetIndex, index, status);
    }
    var color = context.option.theme.sankeyTheme.linkColor;
    if (color != null) {
      return AreaStyle(color: context.option.theme.sankeyTheme.color);
    }
    var as = getItemStyle(context, sourceData, sourceIndex, status)?.color;
    var ae = getItemStyle(context, targetData, targetIndex, status)?.color;
    if (as != null && ae != null) {
      if (status.contains(ViewState.disabled)) {
        return AreaStyle(shader: LineShader([as.withOpacity(0.5), ae.withOpacity(0.5)]));
      }
    }
    return AreaStyle(color: Colors.grey.withOpacity(0.5));
  }

  LineStyle? getLinkBorderStyle(
    Context context,
    BaseItemData sourceData,
    int sourceIndex,
    BaseItemData targetData,
    int targetIndex,
    int index,
    Set<ViewState> status,
  ) {
    var fun = linkBorderStyleFun;
    if (fun != null) {
      return fun.call(sourceData, sourceIndex, targetData, targetIndex, index, status);
    }
    return null;
  }

  LabelStyle? getLinkLabelStyle(
    Context context,
    BaseItemData sourceData,
    int sourceIndex,
    BaseItemData targetData,
    int targetIndex,
    int index,
    Set<ViewState> status,
  ) {
    var fun = linkLabelStyleFun;
    if (fun != null) {
      return fun.call(sourceData, sourceIndex, targetData, targetIndex, index, status);
    }
    return context.option.theme.getLabelStyle();
  }
}

class SankeyData {
  final List<ItemData> data;
  final List<SankeyLinkData> links;

  SankeyData(this.data, this.links);
}

class SankeyLinkData extends ItemData {
  final ItemData src;
  final ItemData target;

  SankeyLinkData(this.src, this.target, super.value, {super.label, super.id});

  @override
  int get hashCode {
    return Object.hash(src, target);
  }

  @override
  bool operator ==(Object other) {
    return other is SankeyLinkData && other.src == src && other.target == target;
  }
}

typedef LinkSort = int Function(SankeyLink, SankeyLink);

typedef NodeSort = int Function(SankeyNode, SankeyNode);
