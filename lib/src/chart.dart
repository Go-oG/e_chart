//表格的通用配置
import 'dart:ui';

import 'package:flutter/material.dart';

import 'animation/animator_props.dart';
import 'core/series.dart';
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
  List<XAxis> xAxisList = [XAxis()];
  List<YAxis> yAxisList = [YAxis()];
  List<PolarConfig> polarList;
  List<RadarConfig> radarList;
  List<ParallelConfig> parallelList;
  List<CalendarConfig> calendarList;
  List<ChartSeries> series;
  AnimatorProps animation;
  GridConfig grid = GridConfig();
  ScaleType scaleType;
  DragType dragType;
  ToolTip? toolTip;
  Color backgroundColor;

  ChartConfig(
      {required this.series,
      this.title,
      this.legend,
      List<XAxis>? xAxisList,
      List<YAxis>? yAxisList,
      this.polarList = const [],
      this.radarList = const [],
      this.parallelList = const [],
      this.calendarList = const [],
      this.animation = const AnimatorProps(),
      GridConfig? grid,
      this.scaleType = ScaleType.scale,
      this.dragType = DragType.longPress,
      this.toolTip,
      this.backgroundColor = const Color(0xFFFFFFFF)}) {
    if (xAxisList != null) {
      this.xAxisList = xAxisList;
    }
    if (yAxisList != null) {
      this.yAxisList = yAxisList;
    }
    if (grid != null) {
      this.grid = grid;
    }
  }
}
