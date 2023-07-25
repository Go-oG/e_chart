import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/utils/normal_list.dart';
import 'package:flutter/animation.dart';

import 'model/axis_group.dart';
import 'model/axis_index.dart';
import 'model/map_node.dart';

abstract class BaseStackLayoutHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends BaseGridSeries<T, P>>
    extends ChartLayout<S, List<P>> {
  List<SingleNode<T, P>> nodeList = [];
  Map<T, SingleNode<T, P>> nodeMap = {};

  List<SingleNode<T, P>> drawNodeList = [];

  @override
  void onLayout(List<P> data, LayoutType type) async {
    AxisGroup<T, P> axisGroup = series.helper.result;
    Map<AxisIndex, List<GroupNode<T, P>>> axisMap = axisGroup.groupMap;
    List<GroupNode<T, P>> newNodeList = [];
    Map<T, SingleNode<T, P>> newNodeMap = {};
    axisMap.forEach((key, value) {
      newNodeList.addAll(value);
      for (var cv in value) {
        for (var ele in cv.nodeList) {
          for (var element in ele.nodeList) {
            if (element.data != null) {
              newNodeMap[element.data!] = element;
            }
          }
        }
      }
    });

    ///开始布局
    var sw = Stopwatch();
    sw.start();
    List<Future> futureList = [];
    axisMap.forEach((key, value) {
      ///布局Group
      List<List<GroupNode<T, P>>> spList = splitList(value, 500);
      for (var gl in spList) {
        var f = Future(() async {
          for (var groupNode in gl) {
            var xIndex = key;
            if (groupNode.nodeList.isEmpty) {
              return;
            }
            var x = groupNode.getX();

            ///布局当前组的位置
            onLayoutGroup(groupNode, xIndex, x);

            ///布局组里面的列
            onLayoutColumn(axisGroup, groupNode, xIndex, x);

            ///布局列里面的节点
            for (var nl in groupNode.nodeList) {
              onLayoutNode(nl, xIndex);
            }
          }
        });
        futureList.add(f);
      }
    });

    for (var f in futureList) {
      await f;
    }

    sw.stop();
    logPrint("$runtimeType onLayout() 耗时:${sw.elapsedMilliseconds}ms");
    sw.start();
    await onLayoutEnd(nodeList, nodeMap, List.from(newNodeMap.values), newNodeMap, type);
    sw.stop();
    logPrint("$runtimeType onLayout() execute onLayoutEnd 耗时:${sw.elapsedMilliseconds}ms");
    notifyLayoutUpdate();
  }

  Future<void> onLayoutEnd(List<SingleNode<T, P>> oldNodeList, Map<T, SingleNode<T, P>> oldNodeMap, List<SingleNode<T, P>> newNodeList,
      Map<T, SingleNode<T, P>> newNodeMap, LayoutType type) async {
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
      notifyLayoutEnd();
      nodeList = diffResult.finalList;
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

  void onLayoutGroup(GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x);

  void onLayoutColumn(AxisGroup<T, P> axisGroup, GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x);

  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex);

  SingleNode<T, P> onCreateAnimatorObj(SingleNode<T, P> data, SingleNode<T, P> node, bool newData, LayoutType type);

  void onAnimatorStart(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type);

  void onAnimatorUpdate(
    SingleNode<T, P> node,
    double t,
    Map<SingleNode<T, P>, MapNode> startMap,
    Map<SingleNode<T, P>, MapNode> endMap,
    LayoutType type,
  );

  void onAnimatorUpdateEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, double t, LayoutType type);

  void onAnimatorEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type);

  List<DynamicData> getAxisExtreme(S series, int axisIndex, bool isXAxis) {
    CoordSystem system = CoordSystem.grid;
    if (series.coordSystem == CoordSystem.polar) {
      system = CoordSystem.polar;
    }

    List<DynamicData> dl = [];
    if (!isXAxis) {
      for (var d in series.helper.getExtreme(system, axisIndex)) {
        dl.add(DynamicData(d));
      }
      return dl;
    }

    for (var group in series.data) {
      if (group.data.isEmpty) {
        continue;
      }
      int xIndex = group.xAxisIndex;
      if (xIndex < 0) {
        xIndex = 0;
      }
      if (isXAxis && xIndex != axisIndex) {
        continue;
      }
      for (var data in group.data) {
        if (data != null) {
          dl.add(data.x);
        }
      }
    }
    return dl;
  }

  Offset getTranslation();

  void onGridScrollChange(Offset offset) {}

  void onGridScrollEnd(Offset offset) {}

  ///=======================
  SingleNode<T, P>? oldHoverNode;

  void handleHoverOrClick(Offset offset, bool click) {
    Offset tr = getTranslation();
    offset = offset.translate(tr.dx, tr.dy);
    var node = findNode(offset);
    if (node == oldHoverNode) {
      return;
    }
    if (series.selectedMode == SelectedMode.group && node?.parentNode == oldHoverNode?.parentNode) {
      return;
    }
    onHandleHoverEnd(oldHoverNode, node);
  }

  void onHandleHoverEnd(SingleNode<T, P>? oldNode, SingleNode<T, P>? newNode) {
    var states = [ViewState.focused, ViewState.hover, ViewState.disabled];
    var states2 = [ViewState.focused, ViewState.hover];
    each(nodeList, (group, i) {
      for (var ele in group.parentNode.nodeList) {
        nodeMap[ele]?.removeStates(states);
        if (newNode == null) {
          continue;
        }
        if (ele.data == newNode.data || (group.parent == newNode.parent && series.selectedMode == SelectedMode.group)) {
          nodeMap[ele]?.addStates(states2);
        } else {
          nodeMap[ele]?.addState(ViewState.disabled);
        }
      }
    });

    Map<SingleNode<T, P>, AreaStyle?> oldAreStyleMap = {};
    Map<SingleNode<T, P>, LineStyle?> oldLineStyleMap = {};

    Map<SingleNode<T, P>, AreaStyle?> newAreStyleMap = {};
    Map<SingleNode<T, P>, LineStyle?> newLineStyleMap = {};

    each(nodeList, (node, p1) {
      oldAreStyleMap[node] = node.areaStyle;
      oldLineStyleMap[node] = node.lineStyle;
      newAreStyleMap[node] = buildAreaStyle(node.data, node.parent, node.groupIndex, node.status);
      newLineStyleMap[node] = buildLineStyle(node.data, node.parent, node.groupIndex, node.status);
      node.areaStyle = null;
      node.lineStyle = null;
    });

    ChartDoubleTween doubleTween = ChartDoubleTween(props: series.animatorProps);
    AreaStyleTween areaTween = AreaStyleTween(const AreaStyle(), const AreaStyle());
    LineStyleTween lineTween = LineStyleTween(const LineStyle(), const LineStyle());
    doubleTween.addListener(() {
      double t = doubleTween.value;
      each(nodeList, (node, p1) {
        var oa = oldAreStyleMap[node];
        var ol = oldLineStyleMap[node];
        var na = newAreStyleMap[node];
        var nl = newLineStyleMap[node];
        if (oa != null && na != null) {
          areaTween.changeValue(oa, na);
          node.areaStyle = areaTween.safeGetValue(t);
        } else {
          node.areaStyle = oa ?? na;
        }
        if (ol != null && nl != null) {
          lineTween.changeValue(ol, nl);
          node.lineStyle = lineTween.safeGetValue(t);
        } else {
          node.lineStyle = ol ?? nl;
        }
      });
      notifyLayoutUpdate();
    });
    oldHoverNode = newNode;
    doubleTween.start(context, true);
  }

  void clearHover() {
    if (oldHoverNode == null) {
      return;
    }
    onHandleHoverEnd(oldHoverNode, null);
  }

  SingleNode<T, P>? findNodeByData(T? data) {
    return nodeMap[data];
  }

  SingleNode<T, P>? findNode(Offset offset) {
    for (var ele in nodeList) {
      if (ele.rect.contains(offset)) {
        return ele;
      }
    }
    return null;
  }

  AreaStyle? buildAreaStyle(T? data, P group, int groupIndex, Set<ViewState>? status);

  LineStyle? buildLineStyle(T? data, P group, int groupIndex, Set<ViewState>? status);
}
