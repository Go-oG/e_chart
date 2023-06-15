import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/point/point_layout.dart';
import 'package:flutter/material.dart';

class PointView extends SeriesView<PointSeries> with PolarChild, CalendarChild {
  final PointLayout _layout = PointLayout();

  PointView(super.series);

  @override
  void onClick(Offset offset) {
    PointNode? clickNode;
    var nodeList = _layout.nodeList;
    for (var node in nodeList) {
      if (series.includeFun != null && series.includeFun!.call(node, offset)) {
        clickNode = node;
        break;
      }
      if (node.rect.contains(offset)) {
        clickNode = node;
        break;
      }
    }
    for (var node in nodeList) {
      node.select = node == clickNode;
    }
    invalidate();
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _layout.doLayout(context, series, series.data, width, height);
  }

  @override
  void onDraw(Canvas canvas) {
    for (var node in _layout.nodeList) {
      ChartSymbol symbol = series.symbolStyle.call(node);
      symbol.draw(canvas, mPaint, node.rect.center);
    }
  }

  void drawForPolar(Canvas canvas, PolarCoord coord) {}

  void drawForCalendar(Canvas canvas, CalendarCoord coord) {}

  void drawForGrid(Canvas canvas, GridCoord coord) {}

  @override
  int get calendarIndex => series.calendarIndex;

  @override
  List<DynamicData> get angleDataSet {
    List<DynamicData> dl = [];
    for (var ele in series.data) {
      dl.add(ele.y);
    }
    return dl;
  }

  @override
  List<DynamicData> get radiusDataSet {
    List<DynamicData> dl = [];
    for (var ele in series.data) {
      dl.add(ele.x);
    }
    return dl;
  }
}
