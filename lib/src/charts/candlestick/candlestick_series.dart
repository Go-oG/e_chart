import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/candlestick/candlestick_view.dart';

class CandleStickSeries extends GridSeries<CandleStickData, CandleStickGroup> {
  CandleStickSeries(
    super.data, {
    super.dynamicRange = true,
    super.gridIndex = 0,
    super.areaStyleFun,
    super.columnGap = SNumber.zero,
    super.corner,
    super.groupGap = SNumber.zero,
    super.groupStyleFun,
    super.innerGap = 0,
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
    super.animation =
        const AnimatorOption(duration: Duration(milliseconds: 400), updateDuration: Duration(milliseconds: 300)),
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.clip,
  }) : super(
            coordType: CoordType.grid,
            polarIndex: -1,
            direction: Direction.vertical,
            realtimeSort: false,
            selectedMode: SelectedMode.single);

  @override
  ChartView? toView() {
    return CandleStickView(this);
  }

  @override
  AreaStyle getAreaStyle(Context context, StackData<CandleStickData, CandleStickGroup> data, CandleStickGroup group) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group) ?? AreaStyle.empty;
    }
    if (data.dataIsNull) {
      return AreaStyle.empty;
    }
    var theme = context.option.theme.kLineTheme;
    if (theme.fill) {
      Color color = data.data.isUp ? theme.upColor : theme.downColor;
      return AreaStyle(color: color).convert(data.status);
    }
    return AreaStyle.empty;
  }

  @override
  LineStyle getLineStyle(Context context, var data, CandleStickGroup group) {
    if (lineStyleFun != null) {
      return lineStyleFun!.call(data, group) ?? LineStyle.empty;
    }
    if (data.dataIsNull) {
      return LineStyle.empty;
    }
    var theme = context.option.theme.kLineTheme;
    Color color = data.data.isUp ? theme.upColor : theme.downColor;
    return LineStyle(color: color, width: theme.borderWidth).convert(data.status);
  }

  @override
  SeriesType get seriesType => SeriesType.candlestick;
}

class CandleStickGroup extends StackGroupData<CandleStickData,CandleStickGroup> {
  CandleStickGroup(
    super.data, {
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    super.barMaxSize,
    super.barMinSize,
    super.barSize = const SNumber.percent(80),
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
    super.name,
    super.id,
  }) : super(time, max([highest, close]));

  bool get isUp => close >= lastClose;

  @override
  num get minValue => lowest;

  @override
  num get maxValue => highest;

  @override
  num get aveValue => (lowest + highest) / 2;

  @override
  String toString() {
    return '$runtimeType time:$time name:$name id:$id\n'
        'highest:${highest.toStringAsFixed(2)} lowest:${lowest.toStringAsFixed(2)}\n'
        'open:${open.toStringAsFixed(2)} close:${close.toStringAsFixed(2)} '
        'lastClose:${lastClose.toStringAsFixed(2)}';
  }
}
