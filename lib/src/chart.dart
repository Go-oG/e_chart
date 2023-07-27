import 'package:e_chart/src/component/brush/brush.dart';

import 'animation/animator_attrs.dart';
import 'coord/index.dart';
import 'core/series.dart';
import 'component/legend/legend.dart';
import 'component/title/title.dart';
import 'component/tooltip/tool_tip.dart';

import 'model/enums/drag_type.dart';
import 'model/enums/scale_type.dart';
import 'component/theme/theme.dart';

///表格的通用配置
class ChartConfig {
  ChartTitle? title;
  Legend? legend;
  List<GridConfig> gridList;
  List<PolarConfig> polarList;
  List<RadarConfig> radarList;
  List<ParallelConfig> parallelList;
  List<CalendarConfig> calendarList;
  List<ChartSeries> series;
  AnimatorAttrs animation;
  ScaleType scaleType;
  DragType dragType;
  ToolTip? toolTip;
  Brush? brush;
  ChartTheme theme = ChartTheme();

  ChartConfig(
      {required this.series,
      this.title,
      this.legend,
      this.gridList = const [],
      this.polarList = const [],
      this.radarList = const [],
      this.parallelList = const [],
      this.calendarList = const [],
      this.animation = const AnimatorAttrs(),
      GridConfig? grid,
      this.scaleType = ScaleType.scale,
      this.dragType = DragType.longPress,
      this.toolTip,
      this.brush,
      ChartTheme? theme}) {
    if (theme != null) {
      this.theme = theme;
    }
  }
}
