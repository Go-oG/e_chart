import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'point_node.dart';

class PointHelper extends LayoutHelper2<PointNode, PointSeries> {
  PointHelper(super.context, super.view, super.series);

  RBush<PointNode> rBush = RBush((p0) => p0.left, (p0) => p0.top, (p0) => p0.right, (p0) => p0.bottom);

  List<PointNode> showNodeList = [];

  @override
  void doLayout(Rect boxBound, Rect globalBoxBound, LayoutType type) {
    if (series.coordType == CoordType.grid) {
      subscribeAxisScrollEvent();
    }
    subscribeAxisChangeEvent();
    super.doLayout(boxBound, globalBoxBound, type);
  }

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
      getAnimation(type, oldList.length + newList.length),
      oldList,
      newList,
      (node, add) {
        return add ? 0 : node.symbol.scale;
      },
      (node, add) => add ? 1 : 0,
      (node, t) {
        node.symbol.scale = t;
      },
      (resultList, t) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
      onStart: () {
        inAnimation = true;
        var tmp = [...oldList, ...newList];
        rBush.clear();
        rBush.addAll(tmp);
        updateShowNodeList();
      },
      onEnd: () {
        inAnimation = false;
        rBush.clear();
        rBush.addAll(newList);
        updateShowNodeList();
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
    Logger.w('暂不支持其它坐标系 ${series.coordType}');
  }

  void _layoutForCalendar(List<PointNode> nodeList, CalendarCoord coord) {
    for (var node in nodeList) {
      DateTime t;
      if (node.data.x.isDate) {
        t = node.data.x.value;
      } else if (node.data.y.isDate) {
        t = node.data.y.value;
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
      var x = coord.dataToPoint(node.group.xAxisIndex, node.data.x, true);
      var y = coord.dataToPoint(node.group.yAxisIndex, node.data.y, false);
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

  void updateShowNodeList() async {
    Offset translation = getTranslation();
    var rect = boxBound.translate(-translation.dx, -translation.dy);
    var list = rBush.search2(rect);
    sortList(list);
    showNodeList = list;
    notifyLayoutUpdate();
  }

  @override
  int getAnimatorCountLimit() {
    return showNodeList.length;
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    if (series.coordType == CoordType.grid ||
        series.coordType == CoordType.polar ||
        series.coordType == CoordType.calendar) {
      return;
    }

    view.translationX += diff.dx;
    view.translationY += diff.dy;
    updateShowNodeList();
    notifyLayoutUpdate();
  }

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
    sortList(showNodeList);
    List<ChartTween> tl = [];
    for (var diff in list) {
      var node = diff.node;
      var scale = diff.startAttr.symbolScale;
      var end = diff.old ? 1 : (1 + 8 / node.symbol.size.shortestSide);
      var tw = ChartDoubleTween(option: animation);
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

  @override
  PointNode? findNode(Offset offset, [bool overlap = false]) {
    var hoveNode = oldHoverNode;
    if (hoveNode != null && hoveNode.contains(offset)) {
      return hoveNode;
    }
    var rect = Rect.fromCenter(center: offset, width: 8, height: 8);
    var result = rBush.search2(rect);
    for (var p in result) {
      if (p.contains(offset)) {
        return p;
      }
    }
    return null;
  }

  @override
  void onAxisScroll(AxisScrollEvent event) {
    if (event.coordType != CoordType.grid || series.coordType != CoordType.grid) {
      return;
    }
    if (event.coordViewId != findGridCoord().id) {
      return;
    }
    updateShowNodeList();
    view.markDirty();
  }

  @override
  void onAxisChange(AxisChangeEvent event) {
    if (event.coordViewId != findGridCoord().id) {
      return;
    }
    onLayout(LayoutType.none);
  }
}
