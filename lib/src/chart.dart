import 'package:e_chart/e_chart.dart';

///表格的通用配置
class ChartConfig {
  ChartTitle? title;
  Legend? legend;
  List<Grid> gridList;
  List<Polar> polarList;
  List<Radar> radarList;
  List<Parallel> parallelList;
  List<Calendar> calendarList;
  List<ChartSeries> series;
  AnimatorAttrs animation;
  ScaleType scaleType;
  DragType dragType;
  ToolTip? toolTip;
  Brush? brush;
  ChartTheme theme = ChartTheme();

  VoidFun1<ChartEvent>? eventCall;

  ChartConfig({
    required this.series,
    this.title,
    this.legend,
    this.gridList = const [],
    this.polarList = const [],
    this.radarList = const [],
    this.parallelList = const [],
    this.calendarList = const [],
    this.animation = const AnimatorAttrs(),
    Grid? grid,
    this.scaleType = ScaleType.scale,
    this.dragType = DragType.longPress,
    this.toolTip,
    this.brush,
    ChartTheme? theme,
    this.eventCall,
  }) {
    if (theme != null) {
      this.theme = theme;
    }
  }
}
