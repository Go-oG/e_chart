import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/utils/shape_util.dart';
import 'package:flutter/rendering.dart';
import 'point_node.dart';

class PointHelper extends LayoutHelper2<PointNode, PointSeries> {
  PointHelper(super.context, super.view, super.series);

  RBush<PointNode> rBush = RBush((p0) => p0.left, (p0) => p0.top, (p0) => p0.right, (p0) => p0.bottom);

  List<PointNode> showNodeList = [];

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
      (resultList) {
        nodeList = resultList;
        notifyLayoutUpdate();
      },
      () {
        inAnimation = true;
        var tmp = [...oldList, ...newList];
        rBush.clear();
        rBush.addAll(tmp);
        updateShowNodeList();
      },
      () {
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

  void updateShowNodeList() async {
    var rect = boxBound.translate(-translationX, -translationY);
    var list = rBush.search2(rect);
    sortList(list);

    int rowCount = 10;
    int colCount = 10;
    int oldCount = list.length;

    List<List<List<PointNode>>> spList = List.generate(rowCount, (index) => List.generate(colCount, (in2) => []));
    var cellH = rect.height / rowCount;
    var cellW = rect.width / colCount;
    for (var node in list) {
      int row = ((node.attr.dy - rect.top) / cellH).floor();
      if (row < 0) {
        row = 0;
      }
      if (row >= rowCount) {
        row = rowCount - 1;
      }
      int col = ((node.attr.dx - rect.left) / cellW).floor();
      if (col < 0) {
        col = 0;
      }
      if (col >= colCount) {
        col = colCount - 1;
      }

      spList[row][col].add(node);
    }

    List<Future<List<PointNode>>> futureList = [];
    list = [];
    for (var rows in spList) {
      for (var cell in rows) {
        if (cell.length > 50) {
          var f = Future<List<PointNode>>(() {
            int old = cell.length;
            var rl = removeOverlapCircle<PointNode>(cell, (p0) => p0.attr, (p0) => p0.symbol.size.shortestSide / 2);
            debugPrint("处理前:$old 处理后:${rl.length}");
            return rl;
          });
          futureList.add(f);
        } else {
          list.addAll(cell);
        }
      }
    }

    for (var f in futureList) {
      list.addAll(await f);
    }
    sortList(list);
    showNodeList = list;
    debugPrint('优化前:${oldCount} 优化后:${list.length}');
    notifyLayoutUpdate();
  }

  @override
  int getAnimatorCountLimit() {
    return showNodeList.length;
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
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
  void onCoordScrollUpdate(CoordScroll scroll) {
    super.onCoordScrollUpdate(scroll);
    view.translationX = scroll.scroll.dx;
    view.translationY = scroll.scroll.dy;
    updateShowNodeList();
    view.markDirty();
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
}
