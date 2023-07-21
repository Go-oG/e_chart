import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

import 'model/axis_group.dart';
import 'model/axis_index.dart';

///适用于极坐标系和笛卡尔坐标系的布局器
abstract class BaseGridLayoutHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends BaseGridSeries<T, P>>
    extends ChartLayout<S, List<P>> {
  List<SingleNode<T, P>> nodeList = [];
  Map<T, SingleNode<T, P>> nodeMap = {};

  SingleNode<T, P>? findNodeByData(T? data) {
    return nodeMap[data];
  }

  @nonVirtual
  @override
  void onLayout(List<P> data, LayoutType type) {
    AxisGroup<T, P> axisGroup = series.helper.result;
    bool vertical = series.direction == Direction.vertical;
    Map<AxisIndex, List<GroupNode<T, P>>> axisMap = axisGroup.groupMap;

    final DynamicData tmpData = DynamicData(1000000);
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

    bool usePolar = series.coordSystem == CoordSystem.polar;

    ///开始布局
    axisMap.forEach((key, value) {
      ///布局Group
      for (var groupNode in value) {
        var xIndex = key;
        if (groupNode.nodeList.isEmpty) {
          continue;
        }
        var x = groupNode.getX();
        if (usePolar) {
          int polarIndex = series.polarIndex;
          var coord = context.findPolarCoord(polarIndex);
          PolarPosition position;
          if (vertical) {
            position = coord.dataToPosition(x, tmpData.change(groupNode.nodeList.first.getUp()));
          } else {
            position = coord.dataToPosition(tmpData.change(groupNode.nodeList.first.getUp()), x);
          }
          num ir = position.radius.length == 1 ? 0 : position.radius[0];
          num or = position.radius.length == 1 ? position.radius[0] : position.radius[1];
          num sa = position.angle.length < 2 ? coord.getStartAngle() : position.angle[0];
          num ea = position.angle.length >= 2 ? position.angle[1] : position.angle[0];
          groupNode.arc = Arc(center: position.center, innerRadius: ir, outRadius: or, startAngle: sa, sweepAngle: ea - sa);
          onLayoutColumnForPolar(axisGroup, groupNode, xIndex, x);
        } else {
          var coord = findGridCoord();
          int yIndex = groupNode.getYAxisIndex();
          if (vertical) {
            var rect = coord.dataToRect(xIndex.axisIndex, x, yIndex, tmpData.change(groupNode.nodeList.first.getUp()));
            groupNode.rect = Rect.fromLTWH(rect.left, 0, rect.width, height);
          } else {
            var rect = coord.dataToRect(xIndex.axisIndex, tmpData.change(groupNode.nodeList.first.getUp()), yIndex, x);
            groupNode.rect = Rect.fromLTWH(0, rect.top, width, rect.height);
          }
          onLayoutColumnForGrid(axisGroup, groupNode, xIndex, x);
        }
        each(groupNode.nodeList, (node, i) {
          usePolar ? onLayoutNodeForPolar(node, xIndex) : onLayoutNodeForGrid(node, xIndex);
        });
      }
    });
    onLayoutEnd(this.nodeList, this.nodeMap, List.from(newNodeMap.values), newNodeMap, type);
  }

  void onLayoutEnd(List<SingleNode<T, P>> oldNodeList, Map<T, SingleNode<T, P>> oldNodeMap, List<SingleNode<T, P>> newNodeList,
      Map<T, SingleNode<T, P>> newNodeMap, LayoutType type) {
    if (series.animation == null) {
      this.nodeList = newNodeList;
      this.nodeMap = newNodeMap;
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
      this.nodeList = diffResult.curList;
    };
    doubleTween.endListener = () {
      onAnimatorEnd(diffResult, type);
      this.nodeList = diffResult.finalList;
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
    this.nodeMap = newNodeMap;
  }

  ///布局GroupNode的Column
  void onLayoutColumnForGrid(AxisGroup<T, P> axisGroup, GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x);

  void onLayoutColumnForPolar(AxisGroup<T, P> axisGroup, GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x);

  ///布局Column里面的子View适用于笛卡尔坐标系
  void onLayoutNodeForGrid(ColumnNode<T, P> columnNode, AxisIndex xIndex) {
    final num up = columnNode.nodeList[columnNode.nodeList.length - 1].up;
    final num down = columnNode.nodeList.first.down;
    final num diff = up - down;
    final bool vertical = series.direction == Direction.vertical;

    ///Rect
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

  ///布局Column里面的子View适用于极坐标系
  void onLayoutNodeForPolar(ColumnNode<T, P> columnNode, AxisIndex xIndex) {
    final num up = columnNode.nodeList[columnNode.nodeList.length - 1].up;
    final num down = columnNode.nodeList.first.down;
    final num diff = up - down;
    final bool vertical = series.direction == Direction.vertical;

    final Arc arc = columnNode.arc;
    final num arcSize = vertical ? arc.sweepAngle : (arc.outRadius - arc.innerRadius).abs();
    num offset = vertical ? arc.startAngle : arc.innerRadius;
    each(columnNode.nodeList, (node, i) {
      num percent = (node.up - node.down) / diff;
      num length = percent * arcSize;
      if (vertical) {
        node.arc = arc.copy(startAngle: offset, sweepAngle: length);
      } else {
        node.arc = arc.copy(innerRadius: offset, outRadius: offset + length);
      }
      offset += length;
      node.position = node.arc.centroid();
    });
  }

  @nonVirtual
  SingleNode<T, P> onCreateAnimatorObj(SingleNode<T, P> data, SingleNode<T, P> node, bool newData, LayoutType type) {
    if (series.coordSystem == CoordSystem.polar) {
      return onCreateAnimatorObjForPolar(data, node, newData, type);
    }
    return onCreateAnimatorObjForGrid(data, node, newData, type);
  }

  SingleNode<T, P> onCreateAnimatorObjForGrid(SingleNode<T, P> data, SingleNode<T, P> node, bool newData, LayoutType type) {
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

  SingleNode<T, P> onCreateAnimatorObjForPolar(SingleNode<T, P> data, SingleNode<T, P> node, bool newData, LayoutType type) {
    var rn = SingleNode<T, P>(node.parentNode, node.wrap, node.stack);
    Arc arc;
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      arc = node.arc.copy(innerRadius: 0, outRadius: 0);
    } else {
      arc = node.arc.copy(outRadius: node.arc.innerRadius);
    }
    rn.arc = arc;
    rn.position = arc.centroid();
    return rn;
  }

  void onAnimatorStart(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type) {}

  ///更新动画节点
  @nonVirtual
  void onAnimatorUpdate(
      SingleNode<T, P> node, double t, Map<SingleNode<T, P>, MapNode> startMap, Map<SingleNode<T, P>, MapNode> endMap, LayoutType type) {
    if (series.coordSystem == CoordSystem.polar) {
      onAnimatorUpdateForPolar(node, t, startMap, endMap, type);
    } else {
      onAnimatorUpdateForGrid(node, t, startMap, endMap, type);
    }
  }

  void onAnimatorUpdateForGrid(
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

  void onAnimatorUpdateForPolar(
      SingleNode<T, P> node, double t, Map<SingleNode<T, P>, MapNode> startMap, Map<SingleNode<T, P>, MapNode> endMap, LayoutType type) {
    var s = startMap[node]!.arc;
    var e = endMap[node]!.arc;
    node.arc = Arc.lerp(s, e, t);
  }

  void onAnimatorUpdateEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, double t, LayoutType type) {}

  void onAnimatorEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type) {}

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

  Offset getTranslation() {
    if (series.coordSystem == CoordSystem.polar) {
      return findPolarCoord().getTranslation();
    }
    return findGridCoord().getTranslation();
  }

  void onGridScrollChange(Offset offset){

  }
  void onGridScrollEnd(Offset offset){}



  ///=======================
  SingleNode<T, P>? _oldNode;

  void handleHoverOrClick(Offset offset, bool click) {
    Offset tr = findGridCoord().getTranslation();
    offset = offset.translate(tr.dx, tr.dy);
    var node = findNode(offset);
    if (node == _oldNode) {
      return;
    }
    if (series.selectedMode == SelectedMode.group && node?.parentNode == _oldNode?.parentNode) {
      return;
    }
    onHandleHoverEnd(_oldNode, node);
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
      newAreStyleMap[node] = buildAreaStyle(node);
      newLineStyleMap[node] = buildLineStyle(node);
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

  SingleNode<T, P>? findNode(Offset offset) {
    for (var ele in nodeList) {
      if (ele.rect.contains(offset)) {
        return ele;
      }
    }
    return null;
  }

  AreaStyle? buildAreaStyle(SingleNode<T, P> node);

  LineStyle? buildLineStyle(SingleNode<T, P> node);





}

class MapNode {
  final Rect rect;
  final Offset offset;
  final Arc arc;

  const MapNode(this.rect, this.offset, this.arc);
}
