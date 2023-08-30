import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/point/point_helper.dart';
import 'package:flutter/material.dart';

class PointView extends CoordChildView<PointSeries, PointHelper> with PolarChild, CalendarChild, GridChild {
  PointView(super.series);

  @override
  void onDraw(Canvas canvas) {
    for (var node in layoutHelper.nodeList) {
      node.onDraw(canvas, mPaint);
    }
  }

  @override
  int get calendarIndex => series.calendarIndex;

  @override
  List<dynamic> getAngleExtreme() {
    List<dynamic> dl = [];
    for (var ele in series.data) {
      for (var e in ele.data) {
        dl.add(e.y);
      }
    }
    return dl;
  }

  @override
  List<dynamic> getRadiusExtreme() {
    List<dynamic> dl = [];
    for (var ele in series.data) {
      for (var e in ele.data) {
        dl.add(e.x);
      }
    }
    return dl;
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    return series.data.length;
  }

  @override
  List<dynamic> getAxisExtreme(int axisIndex, bool isXAxis) {
    if (axisIndex <= 0) {
      axisIndex = 0;
    }
    List<dynamic> dl = [];
    for (var group in series.data) {
      var index = isXAxis ? group.gridXIndex : group.gridYIndex;
      if (index < 0) {
        index = 0;
      }
      if (index != axisIndex) {
        continue;
      }
      for (var e in group.data) {
        dl.add(isXAxis ? e.x : e.y);
      }
    }
    return dl;
  }

  @override
  List getViewPortAxisExtreme(int axisIndex, bool isXAxis, BaseScale scale) {
    return getAxisExtreme(axisIndex, isXAxis);
  }

  @override
  PointHelper buildLayoutHelper() {
    return PointHelper(context, series);
  }
}
