import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/sankey/sankey_view.dart';
import 'package:flutter/material.dart';

class SankeySeries extends RectSeries {
  List<SankeyData> data;
  List<SankeyLinkData> links;
  double nodeWidth;
  double gap;
  int iterationCount;
  SankeyAlign align;
  NodeSort? nodeSort;
  LinkSort? linkSort;
  Direction direction;
  num smooth;
  Fun2<SankeyData, AreaStyle?>? areaStyleFun;
  Fun2<SankeyData, LineStyle?>? borderStyleFun;
  Fun2<SankeyData, LabelStyle?>? labelStyleFun;

  Fun2<SankeyLinkData, AreaStyle>? linkStyleFun;
  Fun2<SankeyLinkData, LineStyle>? linkBorderStyleFun;
  Fun2<SankeyLinkData, LabelStyle>? linkLabelStyleFun;

  SankeySeries({
    required this.data,
    required this.links,
    this.nodeWidth = 32,
    this.gap = 8,
    this.iterationCount = 6,
    this.align = const JustifyAlign(),
    this.direction = Direction.horizontal,
    this.nodeSort,
    this.linkSort,
    this.areaStyleFun,
    this.linkStyleFun,
    this.smooth = 0.5,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.animation = const AnimatorOption(duration: Duration(seconds: 2), curve: Curves.ease),
    super.clip,
  }) : super(gridIndex: -1, polarIndex: -1, radarIndex: -1, calendarIndex: -1, parallelIndex: -1);

  @override
  ChartView? toView() {
    return SankeyView(this);
  }

  AreaStyle? getItemStyle(Context context, SankeyData data) {
    var fun = areaStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return context.option.theme.getAreaStyle(data.dataIndex).convert(data.status);
  }

  LineStyle? getBorderStyle(Context context, SankeyData data) {
    var fun = borderStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return context.option.theme.sankeyTheme.getStyle()?.convert(data.status);
  }

  LabelStyle? getLabelStyle(Context context, SankeyData data) {
    var fun = labelStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return context.option.theme.getLabelStyle();
  }

  AreaStyle getLinkStyle(Context context, SankeyLinkData data) {
    var fun = linkStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    var color = context.option.theme.sankeyTheme.linkColor;
    if (color != null) {
      return AreaStyle(color: context.option.theme.sankeyTheme.color);
    }
    var as = getItemStyle(context, data.source)?.color;
    var ae = getItemStyle(context, data.target)?.color;
    if (as != null && ae != null) {
      if (data.status.contains(ViewState.disabled)) {
        return AreaStyle(shader: LineShader([as.withOpacity(0.5), ae.withOpacity(0.5)]));
      }
    }
    return AreaStyle(color: Colors.grey.withOpacity(0.5));
  }

  LineStyle getLinkBorderStyle(Context context, SankeyLinkData data) {
    var fun = linkBorderStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return LineStyle.empty;
  }

  LabelStyle getLinkLabelStyle(Context context, SankeyLinkData data) {
    var fun = linkLabelStyleFun;
    if (fun != null) {
      return fun.call(data);
    }
    return context.option.theme.getLabelStyle() ?? LabelStyle.empty;
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex = p1 + start;
    });
    return data.length;
  }

  @override
  SeriesType get seriesType => SeriesType.sankey;
}

typedef LinkSort = int Function(SankeyLinkData, SankeyLinkData);

typedef NodeSort = int Function(SankeyData, SankeyData);
