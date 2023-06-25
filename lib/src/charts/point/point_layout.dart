import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PointLayout extends ChartLayout {
  List<PointNode> nodeList = [];
  late Context context;
  late PointSeries series;

  void doLayout(Context context, PointSeries series, List<PointData> dataList, num width, num height) {
    this.context = context;
    this.series = series;
    List<PointNode> nl = [];
    for (var d in dataList) {
      nl.add(PointNode(d));
    }
    if (CoordSystem.polar == series.coordSystem) {
      layoutForPolar(nl, context.findPolarCoord(series.polarAxisIndex));
    } else if (CoordSystem.calendar == series.coordSystem) {
      layoutForCalendar(nl, context.findCalendarCoord(series.calendarIndex));
    } else if (CoordSystem.grid == series.coordSystem) {
      layoutForGrid(nl, context.findGridCoord());
    }
    nodeList = nl;
  }

  void layoutForCalendar(List<PointNode> nodeList, CalendarCoord coord) {
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

  void layoutForPolar(List<PointNode> nodeList, PolarCoord coord) {
    for (var node in nodeList) {
      Offset offset = coord.dataToPoint(node.data.x, node.data.y);
      node.rect = Rect.fromCircle(center: offset, radius: 1);
    }
  }

  void layoutForGrid(List<PointNode> nodeList, GridCoord coord) {
    for (var node in nodeList) {
      node.rect = coord.dataToPoint(series.xAxisIndex, node.data.x, series.yAxisIndex, node.data.y);
    }
  }

}

class PointNode with ViewStateProvider {
  final PointData data;
  Rect rect = Rect.zero;

  PointNode(this.data);
}
