import 'package:e_chart/e_chart.dart';

///表格的通用配置
class ChartOption extends ChartNotifier<Command> {
  ChartTitle? title;
  Legend? legend;
  List<Grid> gridList;
  List<Polar> polarList;
  List<Radar> radarList;
  List<Parallel> parallelList;
  List<Calendar> calendarList;
  List<ChartSeries> series;
  AnimatorOption? animation;
  ToolTip? toolTip;
  ChartTheme theme = ChartTheme();
  Map<EventType, Set<VoidFun1<ChartEvent>>>? eventCall;
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
    this.animation = const AnimatorOption(),
    this.toolTip,
    ChartTheme? theme,
    this.eventCall,
  }) : super(Command.none) {
    if (theme != null) {
      this.theme = theme;
    }
  }

}
