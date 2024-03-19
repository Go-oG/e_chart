import 'package:e_chart/e_chart.dart';

import 'package:e_chart/src/charts/themeriver/theme_river_view.dart';

class ThemeRiverSeries extends ChartListSeries<ThemeRiverData> {
  Direction direction;
  SNumber? minInterval;
  num smooth;

  ThemeRiverSeries(
    super.data, {
    this.direction = Direction.horizontal,
    this.minInterval,
    this.smooth = 0.5,
    super.layoutParams,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.animation,
    super.clip,
    super.borderStyleFun,
    super.itemStyleFun,
    super.labelFormatFun,
    super.labelLineStyleFun,
    super.labelStyle,
    super.labelStyleFun,
    super.name,
    super.useSingleLayer,
  }) : super(gridIndex: -1, calendarIndex: -1, parallelIndex: -1, polarIndex: -1, radarIndex: -1);

  @override
  ChartView? toView(Context context) {
    return ThemeRiverView(context, this);
  }

  @override
  SeriesType get seriesType => SeriesType.themeRiver;
}
