import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'point_node.dart';

class PointHelper extends LayoutHelper2<PointNode, PointSeries> {
  PointHelper(super.context, super.series);

  @override
  void onLayout(LayoutType type) {
    List<PointNode> oldList = nodeList;
    List<PointNode> newList = [];
    each(series.data, (group, i) {
      each(group.data, (e, ci) {
        var node = PointNode(series.getSymbol(context, e, ci, group, {}), group, e, ci, i);
        newList.add(node);
      });
    });
    layoutNode(newList);

    var an = DiffUtil.diffLayout2(
      getAnimation(type,oldList.length+newList.length),
      oldList,
      newList,
      (node, add) {
        return add ? 0 : node.symbol.scale;
      },
      (node, add) => add ? 1 : 0,
      (node, t) {
        node.symbol.scale = t;
      },
      (resultList) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
    );

    context.addAnimationToQueue(an);
  }

  void layoutNode(List<PointNode> nodeList) {
    if (CoordType.polar == series.coordType) {
      _layoutForPolar(nodeList, findPolarCoord());
      return;
    }
    if (CoordType.calendar == series.coordType) {
      _layoutForCalendar(nodeList, findCalendarCoord());
      return;
    }
    if (CoordType.grid == series.coordType) {
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
      var position = coord.dataToPosition(node.data.x, node.data.y);
      node.attr = position.position;
    }
  }

  void _layoutForGrid(List<PointNode> nodeList, GridCoord coord) {
    for (var node in nodeList) {
      var x = coord.dataToPoint(node.group.gridXIndex, node.data.x, true);
      var y = coord.dataToPoint(node.group.gridYIndex, node.data.y, false);
      double ox;
      if (x.length == 1) {
        ox = x.first.dx;
      } else {
        ox = (x.first.dx + x.last.dx) / 2;
      }
      double oy;
      if (y.length == 1) {
        oy = y.first.dy;
      } else {
        oy = (y.first.dy + y.last.dy) / 2;
      }
      node.attr = Offset(ox, oy);
    }
  }


  @override
  SeriesType get seriesType => SeriesType.point;

  @override
  void onRunUpdateAnimation(var list, var animation) {
    List<PointNode> oldList = [];
    List<PointNode> newList = [];
    for (var diff in list) {
      diff.node.drawIndex = diff.old ? 0 : 100;
      if (diff.old) {
        oldList.add(diff.node);
      } else {
        newList.add(diff.node);
      }
    }
    sortList(nodeList);
    List<ChartTween> tl = [];
    for (var diff in list) {
      var node = diff.node;
      var scale = diff.startAttr.symbolScale;
      var end = diff.old ? 1 : (1 + 8 / node.symbol.size.shortestSide);
      var tw = ChartDoubleTween(props: animation);
      tw.addListener(() {
        var t = tw.value;
        node.symbol.scale = lerpDouble(scale, end, t)!;
        node.itemStyle = AreaStyle.lerp(diff.startAttr.itemStyle, diff.endAttr.itemStyle, t);
        node.borderStyle = LineStyle.lerp(diff.startAttr.borderStyle, diff.endAttr.borderStyle, t);
        notifyLayoutUpdate();
      });
      tl.add(tw);
    }
    for (var t in tl) {
      t.start(context, true);
    }
  }
}
