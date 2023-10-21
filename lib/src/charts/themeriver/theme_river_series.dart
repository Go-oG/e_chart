import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/themeriver/theme_river_data.dart';
import 'package:e_chart/src/charts/themeriver/theme_river_view.dart';

class ThemeRiverSeries extends RectSeries {
  List<ThemeRiverData> data;
  Direction direction;
  SNumber? minInterval;
  num smooth;
  Fun2<ThemeRiverData, AreaStyle>? areaStyleFun;
  Fun2<ThemeRiverData, LineStyle?>? borderStyleFun;
  Fun2<ThemeRiverData, LabelStyle?>? labelStyleFun;

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
  }) : super(gridIndex: -1, calendarIndex: -1, parallelIndex: -1, polarIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return ThemeRiverView(this);
  }

  @override
  SeriesType get seriesType => SeriesType.themeRiver;

  AreaStyle getAreaStyle(Context context, ThemeRiverData data) {
    if (areaStyleFun != null) {
      return areaStyleFun!.call(data);
    }
    var theme = context.option.theme;
    return AreaStyle(color: theme.colors[data.styleIndex % theme.colors.length]).convert(data.status);
  }

  LineStyle getBorderStyle(Context context, ThemeRiverData data) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data) ?? LineStyle.empty;
    }
    return LineStyle.empty;
  }

  LabelStyle getLabelStyle(Context context, ThemeRiverData data) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data) ?? LabelStyle.empty;
    }
    var theme = context.option.theme;
    return theme.getLabelStyle() ?? LabelStyle.empty;
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
}
