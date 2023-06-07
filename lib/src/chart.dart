//表格的通用配置
import 'animation/animator_props.dart';
import 'charts/series.dart';
import 'component/legend/legend.dart';
import 'component/title/title.dart';
import 'component/tooltip/tool_tip.dart';
import 'coord/calendar/calendar_config.dart';
import 'coord/grid/axis_x.dart';
import 'coord/grid/axis_y.dart';

import 'coord/grid/grid_config.dart';
import 'coord/parallel/parallel_config.dart';
import 'coord/polar/polar_config.dart';
import 'coord/radar/radar_config.dart';
import 'model/enums/drag_type.dart';
import 'model/enums/scale_type.dart';

class ChartConfig {
  ChartTitle? title;
  Legend? legend;
  List<XAxis> xAxisList;
  List<YAxis> yAxisList;
  List<PolarConfig> polarList;
  List<RadarConfig> radarList;
  List<ParallelConfig> parallelList;
  List<CalendarConfig> calendarList;
  List<ChartSeries> series;
  AnimatorProps animation;
  GridConfig grid;
  ScaleType scaleType;
  DragType dragType;
  ToolTip? toolTip;

  ChartConfig({
    required this.series,
    this.title,
    this.legend,
    this.xAxisList = const [XAxis()],
    this.yAxisList = const [YAxis()],
    this.polarList = const [],
    this.radarList = const [],
    this.parallelList = const [],
    this.calendarList = const [],
    this.animation = const AnimatorProps(),
    this.grid = const GridConfig(),
    this.scaleType = ScaleType.scale,
    this.dragType = DragType.longPress,
    this.toolTip,
  });
}
