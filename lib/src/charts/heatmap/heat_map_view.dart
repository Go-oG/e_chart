import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/heatmap/heat_map_helper.dart';
import 'package:flutter/material.dart';

/// 热力图
class HeatMapView extends SeriesView<HeatMapSeries, HeatMapHelper> with GridChild, CalendarChild {
  HeatMapView(super.context, super.series);

  @override
  void onDraw(CCanvas canvas) {
    var sRect = selfViewPort;
    each(layoutHelper.dataSet, (node, index) {
      Rect rect = node.attr;
      if (!rect.overlaps(sRect)) {
        return;
      }
      node.onDraw(canvas, mPaint);
    });
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    return series.data.length;
  }

  @override
  List<dynamic> getAxisExtreme(int axisIndex, bool isXAxis) {
    List<dynamic> dl = [];
    for (var element in series.data) {
      if (isXAxis) {
        dl.add(element.x);
      } else {
        dl.add(element.y);
      }
    }
    return dl;
  }

  @override
  HeatMapHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.dispose();
    return HeatMapHelper(context, this, series);
  }

  @override
  List getViewPortAxisExtreme(int axisIndex, bool isXAxis, BaseScale scale) {
    return getAxisExtreme(axisIndex, isXAxis);
  }

  @override
  int get calendarIndex => series.calendarIndex;

  @override
  bool get enableDrag => true;

  AreaStyle? getAreaStyle(HeatMapData data) {
    return series.getItemStyle(context, data);
  }

  LineStyle? getBorderStyle(HeatMapData data) {
    return series.getBorderStyle(context, data);
  }
}
