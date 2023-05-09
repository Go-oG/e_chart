//表格的通用配置
import 'animation/animator_props.dart';
import 'charts/series.dart';
import 'component/legend/legend.dart';
import 'component/title/title.dart';
import 'component/tooltip/tool_tip.dart';
import 'coord/calendar/calendar.dart';
import 'coord/grid/axis_x.dart';
import 'coord/grid/axis_y.dart';
import 'coord/grid/grid.dart';
import 'coord/parallel/parallel.dart';
import 'coord/polar/polar.dart';
import 'coord/radar/radar.dart';
import 'model/enums/drag_type.dart';
import 'model/enums/scale_type.dart';

class ChartConfig {
  final ChartTitle? title;
  final Legend? legend;
  final List<XAxis> xAxisList;
  final List<YAxis> yAxisList;
  final List<Polar> polarList;
  final List<Radar> radarList;
  final List<Parallel> parallelList;
  final List<Calendar> calendarList;
  final List<ChartSeries> series;
  final AnimatorProps animation;
  final Grid grid;
  final ScaleType scaleType;
  final DragType dragType;
  final ToolTip? toolTip;

  ChartConfig({
    required this.series,
    this.title,
    this.legend,
    this.xAxisList = const [XAxis()],
    this.yAxisList = const [YAxis()],
    this.polarList = const [Polar()],
    this.radarList = const [],
    this.parallelList = const [],
    this.calendarList = const [],
    this.animation = const AnimatorProps(),
    this.grid = const Grid(),
    this.scaleType = ScaleType.scale,
    this.dragType = DragType.drag,
    this.toolTip,
  });
}
