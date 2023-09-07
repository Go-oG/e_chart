import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'point_node.dart';

class PointHelper extends LayoutHelper2<PointNode, PointSeries> {
  static const String _size = "originSize";
  static const String _center = "originCenter";

  PointHelper(super.context, super.series);

  @override
  void onLayout(LayoutType type) {
    List<PointNode> oldList = nodeList;
    List<PointNode> newList = [];
    each(series.data, (group, i) {
      each(group.data, (e, ci) {
        var node = PointNode(series.symbolFun.call(e, group, {}), group, e, ci, i);
        newList.add(node);
      });
    });
    layoutNode(newList);
    each(newList, (node, p1) {
      node.extSet(_size, node.attr.size);
      node.extSet(_center, node.attr.offset);
    });

    var animation = series.animation;
    if (animation == null || type == LayoutType.none) {
      nodeList = newList;
      return;
    }

    var duration = type == LayoutType.layout ? animation.duration : animation.updateDuration;
    if (duration.inMilliseconds <= 0) {
      nodeList = newList;
      return;
    }

    var an = DiffUtil.diffLayout<PointAttr, PointData, PointNode>(
      animation,
      oldList,
      newList,
      (data, node, add) => PointAttr.all(node.attr.offset, Size.zero),
      (s, e, t) {
        PointAttr size = PointAttr();
        if (s.offset == e.offset) {
          size.offset = e.offset;
        } else {
          size.offset = Offset.lerp(s.offset, e.offset, t)!;
        }
        if (s.size == e.size) {
          size.size = e.size;
        } else {
          size.size = Size.lerp(s.size, e.size, t)!;
        }
        return size;
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
      node.attr.offset = coord.dataToPosition(t).center;
      node.attr.size = node.symbol.size;
    }
  }

  void _layoutForPolar(List<PointNode> nodeList, PolarCoord coord) {
    for (var node in nodeList) {
      PolarPosition position = coord.dataToPosition(node.data.x, node.data.y);
      node.attr.offset = position.position;
      node.attr.size = node.symbol.size;
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
      node.attr.offset = Offset(ox, oy);
      node.attr.size = node.symbol.size;
    }
  }

  @override
  Offset getScroll() {
    if (CoordType.polar == series.coordType) {
      return findPolarCoord().getScroll();
    }
    if (CoordType.calendar == series.coordType) {
      return findCalendarCoord().getScroll();
    }
    if (CoordType.grid == series.coordType) {
      return findGridCoord().getScroll();
    }
    throw ChartError("unSupport Coord");
  }

  @override
  SeriesType get seriesType => SeriesType.point;

  @override
  void onRunUpdateAnimation(var oldNode, var oldAttr, var newNode, var newAttr, var animation) {
    Offset diffSize = const Offset(4, 4);
    List<PointNode> oldList = [];
    if (oldNode != null) {
      oldList.add(oldNode);
    }
    List<PointNode> newList = [];
    if (newNode != null) {
      newList.add(newNode);
    }

    DiffUtil.diffUpdate<PointAttr, PointData, PointNode>(
      context,
      animation,
      oldList,
      newList,
      (data, node, isOld) {
        Offset offset = node.extGet(_center)!;
        Size size = node.extGet(_size)!;
        if (isOld) {
          return PointAttr.all(offset, (size - diffSize) as Size);
        }
        return PointAttr.all(offset, size + diffSize);
      },
      PointAttr.lerp,
      notifyLayoutUpdate,
    );
  }
}
