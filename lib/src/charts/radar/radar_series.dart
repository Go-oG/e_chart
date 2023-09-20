import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/radar/radar_view.dart';

class RadarSeries extends RectSeries {
  List<GroupData> data;
  int splitNumber;
  Fun4<GroupData, int, Set<ViewState>, AreaStyle?>? areaStyleFun;
  Fun4<GroupData, int, Set<ViewState>, LineStyle?>? lineStyleFun;
  Fun4<GroupData, int, Set<ViewState>, LabelStyle>? labelStyleFun;
  Fun5<ItemData, int, GroupData,Set<ViewState>,  ChartSymbol?>? symbolFun;
  num nameGap;

  RadarSeries(
    this.data, {
    required this.splitNumber,
    this.areaStyleFun,
    this.symbolFun,
    this.labelStyleFun,
    this.nameGap = 0,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.radarIndex = 0,
    super.tooltip,
    super.animation,
    super.clip,
    super.backgroundColor,
    super.id,
    super.z,
  }) : super(coordType: CoordType.radar, parallelIndex: -1, gridIndex: -1, calendarIndex: -1, polarIndex: -1);

  @override
  ChartView? toView() {
    return RadarView(this);
  }

  AreaStyle? getAreaStyle(Context context, GroupData group, int index, Set<ViewState> status) {
    var theme = context.option.theme.radarTheme;
    var chartTheme = context.option.theme;
    if (areaStyleFun != null) {
      return areaStyleFun?.call(group, index, status);
    }
    if (theme.fill) {
      Color fillColor = chartTheme.getColor(index);
      return AreaStyle(color: fillColor).convert(status);
    }
    return null;
  }

  LineStyle? getLineStyle(Context context, GroupData group, int index, Set<ViewState> status) {
    var chartTheme = context.option.theme;
    var theme = chartTheme.radarTheme;
    if (lineStyleFun != null) {
      return lineStyleFun?.call(group, index, status);
    }
    if (theme.lineWidth > 0) {
      Color lineColor = chartTheme.getColor(index);
      return LineStyle(color: lineColor, width: theme.lineWidth, dash: theme.dashList).convert(status);
    }
    return null;
  }

  ChartSymbol? getSymbol(Context context, ItemData data,GroupData group, int index, Set<ViewState> status) {
    var chartTheme = context.option.theme;
    var theme = chartTheme.radarTheme;
    if (symbolFun != null) {
      return symbolFun?.call(data, index,group, status);
    }
    if(!theme.showSymbol){
      return null;
    }
    return theme.symbol;
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(data, (item, i) {
      var name = item.name;
      if (name == null || name.isEmpty) {
        return;
      }
      var color = context.option.theme.getColor(i);
      list.add(LegendItem(
        name,
        RectSymbol()..itemStyle = AreaStyle(color: color),
        seriesId: id,
      ));
    });
    return list;
  }

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex=p1+start;
    });
    return data.length;
  }

  @override
  SeriesType get seriesType => SeriesType.radar;
}
