import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/utils/normal_list.dart';
import 'package:flutter/animation.dart';

import 'model/axis_group.dart';
import 'model/axis_index.dart';
import 'model/map_node.dart';

///用于处理堆叠数据的布局帮助者

abstract class BaseStackLayoutHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends BaseGridSeries<T, P>>
    extends ChartLayout<S, List<P>> {
  ///该map存储当前给定数据的映射
  ///如果给定的数据为空则不会存在
  Map<T, SingleNode<T, P>> _nodeMap = {};

  Map<T, SingleNode<T, P>> get nodeMap => _nodeMap;

  ///存储当前屏幕上要显示的节点的数据
  ///其大小不一定等于 [_nodeMap]的大小
  Map<T, SingleNode<T, P>> showNodeMap = {};

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
    List<SingleNode<T, P>> oldNodeList = List.from(_nodeMap.values);
    var oldNodeMap = _nodeMap;
    _nodeMap = newNodeMap;
    await onLayoutEnd(oldNodeList, oldNodeMap, List.from(newNodeMap.values), newNodeMap, type);
    notifyLayoutUpdate();
  }

  ///实现该方法从而布局单个Group(不需要布局其孩子)
  void onLayoutGroup(GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x);

  ///布局GroupNode的孩子(ColumnNode)位置
  void onLayoutColumn(AxisGroup<T, P> axisGroup, GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x);

  ///布局ColumnNode的孩子的位置
  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex);

  ///由[onLayout]最后回调
  ///可以在这里进行动画相关的处理
  Future<void> onLayoutEnd(
    List<SingleNode<T, P>> oldNodeList,
    Map<T, SingleNode<T, P>> oldNodeMap,
    List<SingleNode<T, P>> newNodeList,
    Map<T, SingleNode<T, P>> newNodeMap,
    LayoutType type,
  ) async {
    if (series.animation == null) {
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
    };
    doubleTween.endListener = () {
      onAnimatorEnd(diffResult, type);
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
  }

  ///创建动画的映射对象
  SingleNode<T, P> onCreateAnimatorObj(SingleNode<T, P> data, SingleNode<T, P> node, bool newData, LayoutType type);

  void onAnimatorStart(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type) {
    Map<T, SingleNode<T, P>> map = {};
    for (var ele in result.curList) {
      if (ele.data != null) {
        map[ele.data!] = ele;
      }
    }
    showNodeMap = map;
  }

  void onAnimatorUpdate(
    SingleNode<T, P> node,
    double t,
    Map<SingleNode<T, P>, MapNode> startMap,
    Map<SingleNode<T, P>, MapNode> endMap,
    LayoutType type,
  );

  void onAnimatorUpdateEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, double t, LayoutType type);

  void onAnimatorEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type) {
    Map<T, SingleNode<T, P>> map = {};
    for (var ele in result.finalList) {
      if (ele.data != null) {
        map[ele.data!] = ele;
      }
    }
    showNodeMap = map;
  }

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

  ///==========用户相关操作的处理=============
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
    nodeMap.forEach((key, ele) {
      nodeMap[ele]?.removeStates(states);
      if (newNode == null) {
        return;
      }
      if (ele.data == newNode.data || (ele.parent == newNode.parent && series.selectedMode == SelectedMode.group)) {
        nodeMap[ele]?.addStates(states2);
      } else {
        nodeMap[ele]?.addState(ViewState.disabled);
      }
    });

    Map<SingleNode<T, P>, AreaStyle?> oldAreStyleMap = {};
    Map<SingleNode<T, P>, LineStyle?> oldLineStyleMap = {};

    Map<SingleNode<T, P>, AreaStyle?> newAreStyleMap = {};
    Map<SingleNode<T, P>, LineStyle?> newLineStyleMap = {};

    nodeMap.forEach((key, node) {
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
      nodeMap.forEach((key, node) {
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

  void onHoverEnd() {
    if (oldHoverNode == null) {
      return;
    }
    onHandleHoverEnd(oldHoverNode, null);
  }

  SingleNode<T, P>? findNodeByData(T? data) {
    return nodeMap[data];
  }

  SingleNode<T, P>? findNode(Offset offset) {
    for (var ele in nodeMap.values) {
      if (ele.rect.contains(offset)) {
        return ele;
      }
    }
    return null;
  }

  AreaStyle? buildAreaStyle(T? data, P group, int groupIndex, Set<ViewState>? status);

  LineStyle? buildLineStyle(T? data, P group, int groupIndex, Set<ViewState>? status);
}
