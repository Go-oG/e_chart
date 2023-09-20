import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/themeriver/theme_river_view.dart';

class ThemeRiverSeries extends RectSeries {
  List<GroupData> data;
  Direction direction;
  SNumber? minInterval;
  num smooth;
  Fun4<GroupData, int, Set<ViewState>, AreaStyle>? areaStyleFun;
  Fun4<GroupData, int, Set<ViewState>, LineStyle?>? borderStyleFun;
  Fun4<GroupData, int, Set<ViewState>, LabelStyle?>? labelStyleFun;

  ThemeRiverSeries(
    this.data, {
    this.direction = Direction.horizontal,
    this.minInterval,
    this.labelStyleFun,
    this.smooth = 0.5,
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
  @override
  SeriesType get seriesType => SeriesType.themeriver;

  AreaStyle? getAreaStyle(Context context, GroupData data, int index, Set<ViewState> status) {
    if (areaStyleFun != null) {
      return areaStyleFun!.call(data, index, status);
    }
    var theme = context.option.theme;
    return AreaStyle(color: theme.colors[index % theme.colors.length]).convert(status);
  }

  LineStyle? getBorderStyle(Context context, GroupData data, int index, Set<ViewState> status) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data, index, status);
    }
    return null;
  }

  LabelStyle? getLabelStyle(Context context, GroupData data, int index, Set<ViewState> status) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data, index, status);
    }
    var theme = context.option.theme;
    return theme.getLabelStyle();
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
      p0.styleIndex = p1 + start;
    });
    return data.length;
  }
}
