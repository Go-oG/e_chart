import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CandleStickSeries extends ChartSeries {
  List<CandleStickGroup> data;
  SNumber boxMinWidth;
  SNumber boxMaxWidth;
  SNumber? boxWidth;

  bool hoverAnimation;

  Fun3<CandleStickData, CandleStickGroup, AreaStyle>? areaStyleFun;
  Fun3<CandleStickData, CandleStickGroup, LineStyle>? borderStyleFun;

  CandleStickSeries(
    this.data, {
    super.gridIndex = 0,
    this.boxMinWidth = const SNumber.number(24),
    this.boxMaxWidth = const SNumber.number(48),
    this.boxWidth,
    this.hoverAnimation = true,
    this.areaStyleFun,
    this.borderStyleFun,
    super.name = '',
    super.animation,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
  }) : super(
          coordSystem: CoordSystem.grid,
          parallelIndex: -1,
          polarIndex: -1,
          radarIndex: -1,
          calendarIndex: -1,
        );

  AreaStyle? getAreaStyle(Context context, CandleStickData data, CandleStickGroup group, int groupIndex, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group);
    }
    var theme = context.option.theme.kLineTheme;
    if (theme.fill) {
      Color color = data.isUp ? theme.upColor : theme.downColor;
      return AreaStyle(color: color).convert(status);
    }
    return null;
  }

  LineStyle? getBorderStyle(Context context, CandleStickData data, CandleStickGroup group, int groupIndex, [Set<ViewState>? status]) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data, group);
    }
    var theme = context.option.theme.kLineTheme;
    Color color = data.isUp ? theme.upColor : theme.downColor;
    return LineStyle(color: color, width: theme.borderWidth).convert(status);
  }
}

class CandleStickGroup {
  int xAxisIndex;
  int yAxisIndex;
  List<CandleStickData> data;

  CandleStickGroup(this.data, {this.xAxisIndex = 0, this.yAxisIndex = 0});
}

class CandleStickData {
  DateTime time;
  double highest;
  double lowest;
  double open;
  double close;
  double lastClose;
  DynamicText? label;

  CandleStickData({
    required this.time,
    required this.open,
    required this.close,
    required this.lowest,
    required this.highest,
    required this.lastClose,
    this.label,
  });

  bool get isUp => close >= lastClose;
}
