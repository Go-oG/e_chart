import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'point_node.dart';

class PointHelper extends LayoutHelper<PointSeries> {
  List<PointNode> nodeList = [];

  PointHelper(super.context, super.series);

  @override
  void onLayout(LayoutType type) {
    List<PointNode> oldList = nodeList;
    List<PointNode> newList = [];
    each(series.data, (group, i) {
      each(group.data, (e, ci) {
        var node = PointNode(series.symbolFun.call(e, group), group, e, ci, i, PointSize());
        newList.add(node);
      });
    });
    layoutNode(newList);
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

    var an = DiffUtil.diffLayout2<PointSize, PointData, PointNode>(
      animation,
      oldList,
      newList,
      (data, node, add) => PointSize.all(node.attr.offset, Size.zero),
      (s, e, t) {
        PointSize size = PointSize();
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
      Logger.i("Polar:$position");
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
  void onClick(Offset localOffset) {
    handleHoverAndClick(localOffset, true);
  }

  @override
  void onHoverStart(Offset localOffset) {
    handleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverMove(Offset localOffset) {
    handleHoverAndClick(localOffset, false);
  }

  @override
  void onHoverEnd() {
    var node = _oldNode;
    _oldNode = null;
    if (node == null) {
      return;
    }
    sendHoverOutEvent(node.data, dataIndex: node.dataIndex, groupIndex: node.groupIndex);
    _runUpdateAnimation([node], [], series.animation);
  }

  PointNode? _oldNode;

  void handleHoverAndClick(Offset offset, bool click) {
    Offset scroll = getScroll();
    offset = offset.translate(-scroll.dx, -scroll.dy);
    PointNode? clickNode = findNode(offset);
    if (clickNode == _oldNode) {
      return;
    }

    var old = _oldNode;
    _oldNode = clickNode;

    List<PointNode> oldList = [];
    if (old != null) {
      oldList.add(old);
      sendHoverOutEvent(old.data, dataIndex: old.dataIndex, groupIndex: old.groupIndex);
    }
    List<PointNode> newList = [];
    if (clickNode != null) {
      newList.add(clickNode);
      if (click) {
        sendClickEvent(offset, clickNode.data, dataIndex: clickNode.dataIndex, groupIndex: clickNode.groupIndex);
      } else {
        sendHoverInEvent(offset, clickNode.data, dataIndex: clickNode.dataIndex, groupIndex: clickNode.groupIndex);
      }
    }
    _runUpdateAnimation(oldList, newList, series.animation);
  }

  void _runUpdateAnimation(List<PointNode> oldList, List<PointNode> newList, AnimationAttrs? animation) {
    Offset diffSize = const Offset(4, 4);
    for (var node in oldList) {
      node.removeState(ViewState.selected);
      node.removeState(ViewState.hover);
    }
    for (var node in newList) {
      node.addState(ViewState.selected);
      node.addState(ViewState.hover);
    }

    if (animation == null || animation.updateDuration.inMilliseconds <= 0) {
      for (var node in oldList) {
        node.attr = PointSize.all(node.attr.offset, (node.attr.size - diffSize) as Size);
      }
      for (var node in newList) {
        node.attr = PointSize.all(node.attr.offset, node.attr.size + diffSize);
      }
      notifyLayoutUpdate();
      return;
    }

    DiffUtil.diffUpdate<PointSize, PointData, PointNode>(
      context,
      animation,
      oldList,
      newList,
      (data, node, isOld) {
        if (isOld) {
          return PointSize.all(node.attr.offset, (node.attr.size - diffSize) as Size);
        }
        return PointSize.all(node.attr.offset, node.attr.size + diffSize);
      },
      (s, e, t) {
        PointSize pSize = PointSize();
        pSize.offset = s.offset == e.offset ? e.offset : Offset.lerp(s.offset, e.offset, t)!;
        pSize.size = s.size == e.size ? e.size : Size.lerp(s.size, e.size, t)!;
        return pSize;
      },
      notifyLayoutUpdate,
    );
  }

  PointNode? findNode(Offset offset) {
    var nodeList = this.nodeList;
    for (var node in nodeList) {
      if (node.internal(offset)) {
        return node;
      }
    }
    return null;
  }

  ///获取滚动偏移量
  ///是可以有正负的
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
    throw ChartError("unsupport");
  }

  @override
  SeriesType get seriesType => SeriesType.point;
}
