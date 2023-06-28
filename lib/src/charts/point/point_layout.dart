import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'point_node.dart';

class PointLayout extends ChartLayout<PointSeries, List<PointData>> {
  List<PointNode> nodeList = [];

  @override
  void onLayout(List<PointData> data, LayoutAnimatorType type) {
    List<PointNode> oldList = nodeList;
    List<PointNode> newList = List.from(data.map((e) => PointNode(e)));
    layoutNode(newList);
    nodeList = newList;
  }

  void layoutNode(List<PointNode> nodeList) {
    if (CoordSystem.polar == series.coordSystem) {
      _layoutForPolar(nodeList, context.findPolarCoord(series.polarAxisIndex));
      return;
    }
    if (CoordSystem.calendar == series.coordSystem) {
      _layoutForCalendar(nodeList, context.findCalendarCoord(series.calendarIndex));
      return;
    }
    if (CoordSystem.grid == series.coordSystem) {
      _layoutForGrid(nodeList, context.findGridCoord());
      return;
    }
  }

  void _layoutForCalendar(List<PointNode> nodeList, CalendarCoord coord) {
    for (var node in nodeList) {
      DateTime t;
      if (node.data.x.isDate) {
        t = node.data.x.data;
      } else if (node.data.y.isDate) {
        t = node.data.y.data;
      } else {
        throw ChartError('x 或y 必须有一个是DateTime');
      }
      node.rect = coord.dataToPoint(t);
    }
  }

  void _layoutForPolar(List<PointNode> nodeList, PolarCoord coord) {
    for (var node in nodeList) {
      Offset offset = coord.dataToPoint(node.data.x, node.data.y);
      node.rect = Rect.fromCircle(center: offset, radius: 1);
    }
  }

  void _layoutForGrid(List<PointNode> nodeList, GridCoord coord) {
    for (var node in nodeList) {
      node.rect = coord.dataToPoint(series.xAxisIndex, node.data.x, series.yAxisIndex, node.data.y);
    }
  }


}
