import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/radar/radar_view.dart';

class RadarSeries extends ChartSeries2<RadarData> {
  int splitNumber;
  Fun2<RadarChildData, ChartSymbol?>? symbolFun;
  num nameGap;

  RadarSeries(
    super.data, {
    required this.splitNumber,
    this.symbolFun,
    this.nameGap = 0,
    super.radarIndex = 0,
    super.tooltip,
    super.animation,
    super.clip,
    super.backgroundColor,
    super.id,
    super.borderStyleFun,
    super.itemStyleFun,
    super.labelFormatFun,
    super.labelLineStyleFun,
    super.labelStyle,
    super.labelStyleFun,
    super.name,
    super.useSingleLayer,
  }) : super(coordType: CoordType.radar, parallelIndex: -1, gridIndex: -1, calendarIndex: -1, polarIndex: -1);

  @override
  ChartView? toView() {
    return RadarView(this);
  }

  @override
  AreaStyle getItemStyle(Context context, RadarData data) {
    if (itemStyleFun != null) {
      return super.getItemStyle(context, data);
    }
    var theme = context.option.theme.radarTheme;
    var chartTheme = context.option.theme;
    if (theme.fill) {
      Color fillColor = chartTheme.getColor(data.dataIndex);
      return AreaStyle(color: fillColor).convert(data.status);
    }
    return AreaStyle.empty;
  }

  @override
  LineStyle getBorderStyle(Context context, RadarData data) {
    if (borderStyleFun != null) {
      return super.getBorderStyle(context, data);
    }
    var chartTheme = context.option.theme;
    var theme = chartTheme.radarTheme;
    if (theme.lineWidth > 0) {
      Color lineColor = chartTheme.getColor(data.dataIndex);
      return LineStyle(color: lineColor, width: theme.lineWidth, dash: theme.dashList).convert(data.status);
    }
    return LineStyle.empty;
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
  SeriesType get seriesType => SeriesType.radar;
}
