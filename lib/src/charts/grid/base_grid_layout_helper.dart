import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

abstract class BaseGridLayoutHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends BaseGridSeries<T, P>>
    extends ChartLayout<S, List<P>> {
  List<SingleNode<T, P>> nodeList = [];
  List<GroupNode<T, P>> groupNodeList = [];
  Map<T, SingleNode<T, P>> dataNodeMap = {};

  Offset? getNodePosition(T data) {
    return dataNodeMap[data]?.position;
  }

  List<DynamicData> getAxisExtreme(S series, int axisIndex, bool isXAxis) {
    List<DynamicData> dl = [];
    if (!isXAxis) {
      for (var d in series.helper.getExtreme(axisIndex)) {
        dl.add(DynamicData(d));
      }
      return dl;
    }

    for (var group in series.data) {
      if (group.data.isEmpty) {
        continue;
      }
      int xIndex = group.xAxisIndex ?? series.xAxisIndex;
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

  @nonVirtual
  @override
  void onLayout(List<P> data, LayoutAnimatorType type) {
    AxisGroup<T, P> axisGroup = series.helper.result;
    bool vertical = series.direction == Direction.vertical;
    final DynamicData tmpData = DynamicData(1000000);

    List<SingleNode<T, P>> nodeList = [];
    List<GroupNode<T, P>> gNodeList = [];

    Map<T, SingleNode<T, P>> nodeMap = {};

    ///开始布局
    axisGroup.groupMap.forEach((key, value) {
      List<StackGroup<T, P>> groupList = value;
      List<GroupNode<T, P>> groupNodeList = [];

      ///创建节点
      for (var group in groupList) {
        var groupNode = GroupNode<T, P>(group);
        groupNodeList.add(groupNode);
        List<ColumnNode<T, P>> stackNodeList = [];

        for (var stack in group.column) {
          ColumnNode<T, P> columnNode = ColumnNode(groupNode, stack);
          columnNode.nodeList = buildSingleNode(columnNode, stack.data);
          for (var ele in columnNode.nodeList) {
            var cd = ele.data.data;
            if (cd != null) {
              nodeMap[cd] = ele;
            }
          }
          stackNodeList.add(columnNode);
        }
        groupNode.nodeList = stackNodeList;
      }

      ///布局Group
      for (var groupNode in groupNodeList) {
        var xIndex = key;
        if (groupNode.nodeList.isEmpty) {
          continue;
        }
        var x = groupNode.getX();
        if (series.coordSystem == CoordSystem.polar) {
          var coord = context.findPolarCoord(series.polarAxisIndex);
          PolarPosition position = coord.dataToPosition(x, tmpData.change(groupNode.nodeList.first.getUp()));
          num ir = position.radius.length == 1 ? 0 : position.radius[1];
          num or = position.radius.length == 1 ? position.radius[0] : position.radius[1];
          num sa = position.angle[0];
          num ea = position.angle.length >= 2 ? position.angle[1] : sa;
          groupNode.arc = Arc(
            center: position.center,
            innerRadius: ir,
            outRadius: or,
            startAngle: sa,
            sweepAngle: ea - sa,
          );
        } else {
          var coord = context.findGridCoord();
          Rect areaRect = coord.dataToRect(xIndex.index, x, 0, tmpData.change(groupNode.nodeList.first.getUp()));
          if (vertical) {
            groupNode.rect = Rect.fromLTWH(areaRect.left, 0, areaRect.width, height);
          } else {
            groupNode.rect = Rect.fromLTWH(0, areaRect.top, width, areaRect.height);
          }
        }
        onLayoutGroupColumn(axisGroup, groupNode, xIndex, x);
        each(groupNode.nodeList, (node, i) {
          onLayoutColumn(node, xIndex);
        });
      }
      gNodeList.addAll(groupNodeList);
      for (var node in groupNodeList) {
        for (var cn in node.nodeList) {
          nodeList.addAll(cn.nodeList);
        }
      }
    });
    onLayoutEnd(this.nodeList, this.groupNodeList, this.dataNodeMap, nodeList, gNodeList, nodeMap, type);
  }

  void onLayoutEnd(
    List<SingleNode<T, P>> oldNodeList,
    List<GroupNode<T, P>> oldGroupNodeList,
    Map<T, SingleNode<T, P>> oldNodeMap,
    List<SingleNode<T, P>> newNodeList,
    List<GroupNode<T, P>> newGroupNodeList,
    Map<T, SingleNode<T, P>> newNodeMap,
    LayoutAnimatorType type,
  ) {
    ///动画
    DiffResult<SingleNode<T, P>, SingleData<T, P>> diffResult =
        DiffUtil.diff(oldNodeList, newNodeList, (p0) => p0.data, onCreateAnimatorObj);
    Map<SingleData<T, P>, MapNode> startMap = diffResult.startMap.map((key, value) => MapEntry(
          key,
          MapNode(value.rect, value.position, value.arc),
        ));
    Map<SingleData<T, P>, MapNode> endMap = diffResult.endMap.map((key, value) => MapEntry(
          key,
          MapNode(value.rect, value.position, value.arc),
        ));
    ChartDoubleTween doubleTween = ChartDoubleTween.fromValue(0, 1, props: series.animatorProps);
    doubleTween.startListener = () {
      onAnimatorStart(diffResult);
      this.nodeList = diffResult.curList;
    };
    doubleTween.endListener = () {
      onAnimatorEnd(diffResult);
      this.nodeList = diffResult.finalList;
      notifyLayoutEnd();
    };
    doubleTween.addListener(() {
      double t = doubleTween.value;
      each(diffResult.curList, (node, p1) {
        onAnimatorUpdate(node, t, startMap, endMap);
      });
      onAnimatorUpdateEnd(diffResult);
      notifyLayoutUpdate();
    });
    doubleTween.start(context, type == LayoutAnimatorType.update);
    this.groupNodeList = newGroupNodeList;
    this.dataNodeMap = newNodeMap;
  }

  ///布局GroupNode的Column
  void onLayoutGroupColumn(AxisGroup<T, P> axisGroup, GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x);

  ///布局Column里面的子View
  void onLayoutColumn(ColumnNode<T, P> columnNode, AxisIndex xIndex) {
    final num up = columnNode.nodeList[columnNode.nodeList.length - 1].up;
    final num down = columnNode.nodeList.first.down;
    final num diff = up - down;
    final bool vertical = series.direction == Direction.vertical;

    ///Rect
    final Rect rect = columnNode.rect;
    final double size = vertical ? rect.height : rect.width;
    double bottom = rect.bottom;
    double left = rect.left;

    ///Polar
    final Arc arc = columnNode.arc;
    final num arcSize = vertical ? (arc.outRadius - arc.innerRadius).abs() : arc.sweepAngle;
    double radius = arc.innerRadius.toDouble();
    double angle = arc.startAngle.toDouble();

    for (var node in columnNode.nodeList) {
      num percent = (node.up - node.down) / diff;
      if (series.coordSystem == CoordSystem.polar) {
        double length = percent * arcSize.toDouble();
        if (vertical) {
          node.arc = arc.copy(innerRadius: radius, outRadius: radius + length);
          radius += length;
        } else {
          node.arc = arc.copy(startAngle: angle, sweepAngle: length);
          angle += length;
        }
        node.position = node.rect.center;
      } else {
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
  }

  ///创建动画对象
  SingleNode<T, P> onCreateAnimatorObj(SingleData<T, P> data, SingleNode<T, P> node, bool newData) {
    var dd = SingleData<T, P>(node.data.wrap, node.data.stack);
    var rn = SingleNode<T, P>(node.parent, dd);
    if (series.coordSystem == CoordSystem.polar) {
      final Arc arc = node.arc;
      Arc rr;
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        rr = arc.copy(innerRadius: 0, outRadius: 0);
      } else {
        rr = arc.copy(outRadius: arc.innerRadius);
      }
      rn.arc = rr;
      rn.position = circlePoint((rr.innerRadius + rr.outRadius) / 2, (rr.startAngle + rr.sweepAngle / 2), rr.center);
    } else {
      final Rect rect = node.rect;
      Rect rr;
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        rr = Rect.fromLTWH(rect.left, height, rect.width, 0);
      } else {
        rr = Rect.fromLTWH(rect.left, rect.bottom, rect.width, 0);
      }
      rn.rect = rr;
      rn.position = rr.center;
    }

    return rn;
  }

  void onAnimatorStart(DiffResult<SingleNode<T, P>, SingleData<T, P>> result) {}

  ///更新动画节点
  void onAnimatorUpdate(SingleNode<T, P> node, double t, Map<SingleData<T, P>, MapNode> startMap, Map<SingleData<T, P>, MapNode> endMap) {
    var data = node.data;
    if (series.coordSystem == CoordSystem.polar) {
      var s = startMap[data]!.arc;
      var e = endMap[data]!.arc;
      node.arc = Arc.lerp(s, e, t);
    } else {
      var s = startMap[data]!.rect;
      var e = endMap[data]!.rect;
      Rect r;
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        r = Rect.lerp(s, e, t)!;
      } else {
        r = Rect.fromLTRB(e.left, e.bottom - e.height * t, e.right, e.bottom);
      }
      node.rect = r;
    }
  }

  void onAnimatorUpdateEnd(DiffResult<SingleNode<T, P>, SingleData<T, P>> result) {}

  void onAnimatorEnd(DiffResult<SingleNode<T, P>, SingleData<T, P>> result) {}

  @nonVirtual
  List<SingleNode<T, P>> buildSingleNode(ColumnNode<T, P> stackNode, List<SingleData<T, P>> dataList) {
    List<SingleNode<T, P>> nodeList = [];
    each(dataList, (data, i) {
      SingleNode<T, P> node = SingleNode(stackNode, data);
      nodeList.add(node);
    });
    return nodeList;
  }

  //==============================================================================
  //==============================================================================

  SingleNode<T, P>? _oldNode;

  void handleHoverOrClick(Offset offset, bool click) {
    Offset tr = context.findGridCoord().getTranslation();
    offset = offset.translate(tr.dx, tr.dy);
    var node = findNode(offset);
    if (node == _oldNode) {
      return;
    }
    if (series.selectedMode == SelectedMode.group && node?.data.parent == _oldNode?.data.parent) {
      return;
    }
    onHandleHoverEnd(_oldNode, node);
  }

  void onHandleHoverEnd(SingleNode<T, P>? oldNode, SingleNode<T, P>? newNode) {
    var states = [ViewState.focused, ViewState.hover, ViewState.disabled];
    var states2 = [ViewState.focused, ViewState.hover];
    each(nodeList, (group, i) {
      for (var ele in group.data.parent.data) {
        dataNodeMap[ele]?.removeStates(states);
        if (newNode == null) {
          continue;
        }
        if (ele == newNode.data.data || (group.data.parent == newNode.data.parent && series.selectedMode == SelectedMode.group)) {
          dataNodeMap[ele]?.addStates(states2);
        } else {
          dataNodeMap[ele]?.addState(ViewState.disabled);
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
      newAreStyleMap[node] = generateAreaStyle(node);
      newLineStyleMap[node] = generateLineStyle(node);
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
    _oldNode = newNode;
    doubleTween.start(context, true);
  }

  void clearHover() {
    if (_oldNode == null) {
      return;
    }
    onHandleHoverEnd(_oldNode, null);
  }

  GridAxis findAxis(Context context, int index, bool isXAxis) {
    return context.findGridCoord().getAxis(index, isXAxis);
  }

  SingleNode<T, P>? findNode(Offset offset) {
    for (var ele in nodeList) {
      if (ele.rect.contains(offset)) {
        return ele;
      }
    }
    return null;
  }

  AreaStyle? generateAreaStyle(SingleNode<T, P> node);

  LineStyle? generateLineStyle(SingleNode<T, P> node);
}

class MapNode {
  final Rect rect;
  final Offset offset;
  final Arc arc;

  MapNode(this.rect, this.offset, this.arc);
}
