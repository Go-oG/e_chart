import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/radar/radar_view.dart';

import 'radar_data.dart';

class RadarSeries extends RectSeries {
  List<RadarData> data;
  int splitNumber;
  Fun2<RadarData, AreaStyle?>? areaStyleFun;
  Fun2<RadarData, LineStyle?>? lineStyleFun;
  Fun2<RadarData, LabelStyle>? labelStyleFun;
  Fun2<RadarChildData, ChartSymbol?>? symbolFun;
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
  }) : super(coordType: CoordType.radar, parallelIndex: -1, gridIndex: -1, calendarIndex: -1, polarIndex: -1);

  @override
  ChartView? toView() {
    return RadarView(this);
  }

  AreaStyle? getAreaStyle(Context context, RadarData group) {
    var theme = context.option.theme.radarTheme;
    var chartTheme = context.option.theme;
    if (areaStyleFun != null) {
      return areaStyleFun?.call(group);
    }
    if (theme.fill) {
      Color fillColor = chartTheme.getColor(group.dataIndex);
      return AreaStyle(color: fillColor).convert(group.status);
    }
    return null;
  }

  LineStyle? getLineStyle(Context context, RadarData group) {
    var chartTheme = context.option.theme;
    var theme = chartTheme.radarTheme;
    if (lineStyleFun != null) {
      return lineStyleFun?.call(group);
    }
    if (theme.lineWidth > 0) {
      Color lineColor = chartTheme.getColor(group.dataIndex);
      return LineStyle(color: lineColor, width: theme.lineWidth, dash: theme.dashList).convert(group.status);
    }
    return null;
  }

  ChartSymbol? getSymbol(Context context, RadarChildData data) {
    var chartTheme = context.option.theme;
    var theme = chartTheme.radarTheme;
    if (symbolFun != null) {
      return symbolFun?.call(data);
    }
    if (!theme.showSymbol) {
      return null;
    }
    return theme.symbol;
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(data, (item, i) {
      var name = item.label.text;
      if (name.isEmpty) {
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
      p0.styleIndex = p1 + start;
    });
    return data.length;
  }

  @override
  SeriesType get seriesType => SeriesType.radar;
}
