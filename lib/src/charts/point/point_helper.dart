import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'point_node.dart';

class PointHelper extends LayoutHelper<PointSeries, List<PointData>> {
  List<PointNode> nodeList = [];

  PointHelper(super.context, super.series);

  @override
  void onLayout(List<PointData> data, LayoutType type) {
    List<PointNode> oldList = nodeList;
    List<PointNode> newList =[];
    each(data, (e, i) {
      newList.add(PointNode(e, i, -1, Offset.zero));
    });

    layoutNode(newList);
    nodeList = newList;
  }

  void layoutNode(List<PointNode> nodeList) {
    if (CoordSystem.polar == series.coordSystem) {
      _layoutForPolar(nodeList, findPolarCoord());
      return;
    }
    if (CoordSystem.calendar == series.coordSystem) {
      _layoutForCalendar(nodeList, findCalendarCoord());
      return;
    }
    if (CoordSystem.grid == series.coordSystem) {
      _layoutForGrid(nodeList, findGridCoord());
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
      node.attr = coord.dataToPosition(t).center;
    }
  }

  void _layoutForPolar(List<PointNode> nodeList, PolarCoord coord) {
    for (var node in nodeList) {
      PolarPosition position = coord.dataToPosition(node.data.x, node.data.y);
      node.attr= circlePoint(position.radius[0], position.angle[0], position.center);
    }
  }

  void _layoutForGrid(List<PointNode> nodeList, GridCoord coord) {
    for (var node in nodeList) {
      //TODO 轴
      node.attr = coord.dataToRect(0, node.data.x, 0, node.data.y).center;
    }
  }

  @override
  SeriesType get seriesType => SeriesType.point;
}
