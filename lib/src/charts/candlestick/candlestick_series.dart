import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/candlestick/candlestick_chart.dart';

class CandleStickSeries extends GridSeries<CandleStickData, CandleStickGroup> {
  CandleStickSeries(
    super.data, {
    super.gridIndex = 0,
    super.areaStyleFun,
    super.columnGap,
    super.corner,
    super.groupGap,
    super.groupStyleFun,
    super.innerGap,
    super.labelAlignFun,
    super.labelFormatFun,
    super.labelStyle,
    super.labelStyleFun,
    super.legendHoverLink,
    super.lineStyleFun,
    super.markLine,
    super.markLineFun,
    super.markPoint,
    super.markPointFun,
    super.animation = const AnimatorAttrs(duration: Duration(milliseconds: 800), updateDuration: Duration(milliseconds: 500)),
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
  }) : super(
          coordSystem: CoordSystem.grid,
          polarIndex: -1,
          direction: Direction.vertical,
          realtimeSort: false,
          selectedMode: SelectedMode.single,
        );

  @override
  ChartView? toView() {
    return CandleStickView(this);
  }

  @override
  AreaStyle? getAreaStyle(Context context, CandleStickData? data, CandleStickGroup group, int styleIndex, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group, status ?? {});
    }
    if (data == null) {
      return null;
    }
    var theme = context.option.theme.kLineTheme;
    if (theme.fill) {
      Color color = data.isUp ? theme.upColor : theme.downColor;
      return AreaStyle(color: color).convert(status);
    }
    return null;
  }

  @override
  LineStyle? getLineStyle(Context context, CandleStickData? data, CandleStickGroup group, int styleIndex, [Set<ViewState>? status]) {
    if (lineStyleFun != null) {
      return lineStyleFun!.call(data, group, status ?? {});
    }
    if (data == null) {
      return null;
    }
    var theme = context.option.theme.kLineTheme;
    Color color = data.isUp ? theme.upColor : theme.downColor;
    return LineStyle(color: color, width: theme.borderWidth).convert(status);
  }
}

class CandleStickGroup extends StackGroupData<CandleStickData> {
  CandleStickGroup(
    super.data, {
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    super.barMaxSize,
    super.barMinSize,
    super.barSize,
    super.id,
    super.styleIndex,
  });
}

class CandleStickData extends StackItemData {
  dynamic time;
  double highest;
  double lowest;
  double open;
  double close;
  double lastClose;

  CandleStickData({
    required this.time,
    required this.open,
    required this.close,
    required this.lowest,
    required this.highest,
    required this.lastClose,
    super.label,
    super.id,
  }) : super(time, max([highest, close]));

  bool get isUp => close >= lastClose;
}
