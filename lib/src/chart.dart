import 'package:e_chart/e_chart.dart';

///表格的通用配置
class ChartOption {
  ChartTitle? title;
  Legend? legend;
  List<Grid> gridList;
  List<Polar> polarList;
  List<Radar> radarList;
  List<Parallel> parallelList;
  List<Calendar> calendarList;
  List<ChartSeries> series;
  AnimatorAttrs animation;
  ToolTip? toolTip;
  ChartTheme theme = ChartTheme();
  VoidFun1<ChartEvent>? eventCall;
  int doubleClickInterval = 220;
  int longPressTime = 280;

  ChartOption({
    required this.series,
    this.title,
    this.legend,
    this.gridList = const [],
    this.polarList = const [],
    this.radarList = const [],
    this.parallelList = const [],
    this.calendarList = const [],
    this.animation = const AnimatorAttrs(),
    this.toolTip,
    ChartTheme? theme,
    this.eventCall,
  }) {
    if (theme != null) {
      this.theme = theme;
    }
  }
}
