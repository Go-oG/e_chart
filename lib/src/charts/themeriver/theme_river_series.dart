import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/themeriver/theme_river_view.dart';

class ThemeRiverSeries extends RectSeries {
  List<GroupData> data;
  Direction direction;
  SNumber? minInterval;
  bool smooth;
  Fun4<GroupData,int ,Set<ViewState>, AreaStyle>? areaStyleFun;
  Fun4<GroupData,int,Set<ViewState>, LabelStyle?>? labelStyleFun;

  ThemeRiverSeries(
    this.data, {
    this.direction = Direction.horizontal,
    this.minInterval,
    this.labelStyleFun,
    this.smooth = true,
    this.areaStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.animation,
    super.clip,
    super.z,
  }) : super(gridIndex: -1, calendarIndex: -1, parallelIndex: -1, polarIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return ThemeRiverView(this);
  }
}
