import 'package:e_chart/e_chart.dart';

class CandleStickSeries extends ChartSeries {
  List<CandleStickData> data;
  String name;
  SNumber boxMinWidth;
  SNumber boxMaxWidth;
  SNumber? boxWidth;

  bool hoverAnimation;

  Fun2<CandleStickData, AreaStyle>? styleFun;
  Fun2<CandleStickData, LineStyle>? lineStyleFun;

  CandleStickSeries(
    this.data, {
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    this.boxMinWidth = const SNumber.number(24),
    this.boxMaxWidth = const SNumber.number(48),
    this.boxWidth,
    this.name = '',
    this.hoverAnimation = true,
    this.styleFun,
    this.lineStyleFun,
    super.animation,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.clip,
    super.z,
  }) : super(
          coordSystem: CoordSystem.grid,
          parallelIndex: -1,
          polarAxisIndex: -1,
          radarIndex: -1,
          calendarIndex: -1,
        );
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
