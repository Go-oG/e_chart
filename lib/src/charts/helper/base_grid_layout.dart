import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

import 'base_stack_helper.dart';
import 'model/axis_index.dart';
import 'model/map_node.dart';

///适用于Grid布局器
abstract class BaseGridLayoutHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends BaseGridSeries<T, P>>
    extends BaseStackLayoutHelper<T, P, S> {
  @override
  void onLayoutGroup(GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x) {
    bool vertical = series.direction == Direction.vertical;
    var coord = findGridCoord();
    int yIndex = groupNode.getYAxisIndex();
    final DynamicData tmpData = DynamicData(1000000);
    if (vertical) {
      var rect = coord.dataToRect(xIndex.axisIndex, x, yIndex, tmpData.change(groupNode.nodeList.first.getUp()));
      groupNode.rect = Rect.fromLTWH(rect.left, 0, rect.width, height);
    } else {
      var rect = coord.dataToRect(xIndex.axisIndex, tmpData.change(groupNode.nodeList.first.getUp()), yIndex, x);
      groupNode.rect = Rect.fromLTWH(0, rect.top, width, rect.height);
    }
  }

  @override
  void onLayoutEnd(var oldNodeList, var oldNodeMap, var newNodeList, var newNodeMap, LayoutType type) {
    if (series.animation == null) {
      nodeList = newNodeList;
      nodeMap = newNodeMap;
      return;
    }

    ///动画
    DiffResult<SingleNode<T, P>, SingleNode<T, P>> diffResult = DiffUtil.diff(oldNodeList, newNodeList, (p0) => p0, (a, b, c) {
      return onCreateAnimatorObj(a, b, c, type);
    });

    Map<SingleNode<T, P>, MapNode> startMap = diffResult.startMap.map((key, value) => MapEntry(
          key,
          MapNode(value.rect, value.position, value.arc),
        ));
    Map<SingleNode<T, P>, MapNode> endMap = diffResult.endMap.map((key, value) => MapEntry(
          key,
          MapNode(value.rect, value.position, value.arc),
        ));

    ChartDoubleTween doubleTween = ChartDoubleTween.fromValue(0, 1, props: series.animatorProps);
    doubleTween.startListener = () {
      onAnimatorStart(diffResult, type);
      nodeList = diffResult.curList;
    };
    doubleTween.endListener = () {
      onAnimatorEnd(diffResult, type);
      nodeList = diffResult.finalList;
      notifyLayoutEnd();
    };
    doubleTween.addListener(() {
      double t = doubleTween.value;
      each(diffResult.curList, (node, p1) {
        onAnimatorUpdate(node, t, startMap, endMap, type);
      });
      onAnimatorUpdateEnd(diffResult, t, type);
      notifyLayoutUpdate();
    });
    doubleTween.start(context, type == LayoutType.update);
    nodeMap = newNodeMap;
  }

  @override
  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex) {
    final num up = columnNode.nodeList[columnNode.nodeList.length - 1].up;
    final num down = columnNode.nodeList.first.down;
    final num diff = up - down;
    final bool vertical = series.direction == Direction.vertical;

    final Rect rect = columnNode.rect;
    final double size = vertical ? rect.height : rect.width;
    double bottom = rect.bottom;
    double left = rect.left;
    for (var node in columnNode.nodeList) {
      num percent = (node.up - node.down) / diff;
      double length = percent * size;
      if (vertical) {
        bottom = bottom - length;
        node.rect = Rect.fromLTWH(rect.left, bottom, rect.width, length);
      } else {
        node.rect = Rect.fromLTWH(left, rect.top, length, rect.height);
        left += length;
      }
      node.position = node.rect.center;
    }
  }

  @override
  SingleNode<T, P> onCreateAnimatorObj(SingleNode<T, P> data, SingleNode<T, P> node, bool newData, LayoutType type) {
    var rn = SingleNode<T, P>(node.parentNode, node.wrap, node.stack);
    final Rect rect = node.rect;
    Rect rr;
    if (series.direction == Direction.vertical) {
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        rr = Rect.fromLTWH(rect.left, height, rect.width, 0);
      } else {
        rr = Rect.fromLTWH(rect.left, rect.bottom, rect.width, 0);
      }
    } else {
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        rr = Rect.fromLTWH(0, rect.top, 0, rect.height);
      } else {
        rr = Rect.fromLTWH(rect.left, rect.top, 0, rect.height);
      }
    }
    rn.rect = rr;
    rn.position = rr.center;
    return rn;
  }

  @override
  void onAnimatorStart(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type) {}

  @override
  void onAnimatorUpdate(
      SingleNode<T, P> node, double t, Map<SingleNode<T, P>, MapNode> startMap, Map<SingleNode<T, P>, MapNode> endMap, LayoutType type) {
    var s = startMap[node]!.rect;
    var e = endMap[node]!.rect;
    Rect r;
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      r = Rect.lerp(s, e, t)!;
    } else {
      if (series.direction == Direction.vertical) {
        r = Rect.fromLTRB(e.left, e.bottom - e.height * t, e.right, e.bottom);
      } else {
        r = Rect.fromLTWH(e.left, e.top, e.width * t, e.height);
      }
    }
    node.rect = r;
  }

  @override
  void onAnimatorUpdateEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, double t, LayoutType type) {}

  @override
  void onAnimatorEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type) {}

  @override
  SingleNode<T, P>? findNode(Offset offset) {
    for (var ele in nodeList) {
      if (ele.rect.contains(offset)) {
        return ele;
      }
    }
    return null;
  }

  @override
  Offset getTranslation() {
    return findGridCoord().getTranslation();
  }

}
