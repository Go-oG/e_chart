import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/heatmap/heat_map_helper.dart';
import 'package:flutter/material.dart';

import 'heat_map_node.dart';

/// 热力图
class HeatMapView extends SeriesView<HeatMapSeries, HeatMapHelper> with GridChild, CalendarChild {
  HeatMapView(super.series);

  @override
  void onDraw(Canvas canvas) {
    var coord = layoutHelper.findCalendarCoord();
    var to = coord.getScroll();
    canvas.save();
    canvas.translate(to.dx, to.dy);
    Rect sRect=Rect.fromLTWH(to.dx.abs(), to.dy.abs(), width, height);
    each(layoutHelper.nodeList, (node, index) {
      Rect rect=node.attr;
      if(!rect.overlaps(sRect)){
        return;
      }
      node.onDraw(canvas, mPaint);
    });
    canvas.restore();
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
  HeatMapHelper buildLayoutHelper() {
    return HeatMapHelper(context, series);
  }

  @override
  List getViewPortAxisExtreme(int axisIndex, bool isXAxis, BaseScale scale) {
    return getAxisExtreme(axisIndex, isXAxis);
  }

  @override
  int get calendarIndex => series.calendarIndex;

  AreaStyle? getAreaStyle(HeatMapNode node, int index) {
    return series.getAreaStyle(context, node.data, index, node.status);
  }

  LineStyle? getBorderStyle(HeatMapNode node, int index) {
    return series.getBorderStyle(context, node.data, index, node.status);
  }
}
