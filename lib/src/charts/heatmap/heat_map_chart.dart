import 'package:flutter/material.dart';

import '../../coord/calendar/calendar_child.dart';
import '../../coord/calendar/calendar_coord.dart';
import '../../coord/grid/grid_child.dart';
import '../../coord/grid/grid_coord.dart';
import '../../core/view.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/coordinate.dart';
import '../../style/area_style.dart';
import 'heat_map_series.dart';

/// 热力图
class HeatMapView extends ChartView implements GridChild, CalendarChild {
  final HeatMapSeries series;

  HeatMapView(this.series);

  @override
  int get xAxisIndex => series.xAxisIndex;

  @override
  int get yAxisIndex => series.yAxisIndex;

  @override
  int get xDataSetCount => series.data.length;

  @override
  int get yDataSetCount => series.data.length;

  @override
  List<DynamicData> get xDataSet {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(element.x);
    }
    return dl;
  }

  @override
  List<DynamicData> get yDataSet {
    List<DynamicData> dl = [];
    for (var element in series.data) {
      dl.add(element.y);
    }
    return dl;
  }

  @override
  int get calendarIndex => series.xAxisIndex;

  @override
  void onDraw(Canvas canvas) {
    GridCoord? gridLayout;
    CalendarCoord? calendarLayout;
    if (series.coordSystem == CoordSystem.grid) {
      gridLayout = context.findGridCoord();
    } else {
      calendarLayout = context.findCalendarCoord(calendarIndex);
    }
    for (var data in series.data) {
      AreaStyle? style = series.styleFun.call(data);
      if (style == null) {
        continue;
      }

      Rect? rect;
      if (gridLayout != null) {
        rect = gridLayout.dataToPoint(xAxisIndex, data.x, yAxisIndex, data.y);
      } else if (calendarLayout != null) {
         rect = calendarLayout.dataToPoint(data.x.data);
      }
      if(rect!=null){
        style.drawRect(canvas, mPaint, rect);
      }
    }
  }
}
