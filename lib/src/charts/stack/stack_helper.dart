import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于处理堆叠数据的布局帮助者
///一般用于笛卡尔坐标系和极坐标系的布局
///需要支持部分布局
abstract class StackHelper<T extends StackItemData, P extends StackGroupData<T>, S extends StackSeries<T, P>>
    extends LayoutHelper<S, List<P>> {
  ///该map存储当前给定数据的映射
  ///如果给定的数据为空则不会存在
  Map<T, SingleNode<T, P>> _nodeMap = {};

  Map<T, SingleNode<T, P>> get nodeMap => _nodeMap;

  void updateNodeMap(Map<T, SingleNode<T, P>> map) {
    _nodeMap = map;
  }

  ///存储当前屏幕上要显示的节点的数据
  ///其大小不一定等于 [_nodeMap]的大小
  Map<T, SingleNode<T, P>> showNodeMap = {};

  List<MarkPointNode> markPointList = [];

  List<MarkLineNode> markLineList = [];

  StackHelper(super.context, super.series);

  @override
  void onLayout(List<P> data, LayoutType type) async {
    var helper = series.helper;
    AxisGroup<T, P> axisGroup = helper.result;
    Map<AxisIndex, List<GroupNode<T, P>>> axisMap = axisGroup.groupMap;

    ///实现大数据量下的布局优化
    Map<AxisIndex, List<GroupNode<T, P>>> axisMapTmp = {};
    axisMap.forEach((key, value) {
      axisMapTmp[key] = onComputeNeedLayoutData(helper, key, value);
    });
    axisMap = axisMapTmp;

    Map<T, SingleNode<T, P>> newNodeMap = {};
    axisMap.forEach((key, value) {
      for (var cv in value) {
        for (var ele in cv.nodeList) {
          for (var node in ele.nodeList) {
            if (node.data == null) {
              continue;
            }
            newNodeMap[node.data!] = node;
          }
        }
      }
    });

    ///开始布局
    axisMap.forEach((key, value) {
      ///布局Group
      List<List<GroupNode<T, P>>> spList = splitList(value, 500);
      for (var gl in spList) {
        for (var groupNode in gl) {
          var xIndex = key;
          if (groupNode.nodeList.isEmpty) {
            return;
          }
          var x = groupNode.getXData();

          ///布局当前组的位置
          onLayoutGroup(groupNode, xIndex, x, type);

          ///布局组里面的列
          onLayoutColumn(axisGroup, groupNode, xIndex, x, type);

          ///布局列里面的节点
          for (var cn in groupNode.nodeList) {
            onLayoutNode(cn, xIndex, type);
          }
        }
      }
    });

    List<SingleNode<T, P>> oldNodeList = List.from(_nodeMap.values);
    var oldNodeMap = _nodeMap;
    final List<SingleNode<T, P>> newNodeList = List.from(newNodeMap.values, growable: false);
    _onLayoutMarkPointAndLine(data, newNodeList, newNodeMap);
    await onLayoutEnd(oldNodeList, oldNodeMap, newNodeList, newNodeMap, type);
    notifyLayoutUpdate();
  }

  bool needLayoutForNode(SingleNode<T, P> node, LayoutType type) {
    if (type != LayoutType.none) {
      return true;
    }
    return showNodeMap[node.data!] == null || node.rect.isEmpty;
  }

  ///计算需要布局的数据(默认全部)
  ///子类可以实现该方法从而实现高效的数据刷新
  List<GroupNode<T, P>> onComputeNeedLayoutData(
      DataHelper<T, P, StackSeries> helper, AxisIndex index, List<GroupNode<T, P>> list) {
    return list;
  }

  ///实现该方法从而布局单个Group(不需要布局其孩子)
  void onLayoutGroup(GroupNode<T, P> groupNode, AxisIndex xIndex, dynamic x, LayoutType type);

  ///布局GroupNode的孩子(ColumnNode)位置
  void onLayoutColumn(
      AxisGroup<T, P> axisGroup, GroupNode<T, P> groupNode, AxisIndex xIndex, dynamic x, LayoutType type);

  ///布局ColumnNode的孩子的位置
  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex, LayoutType type);

  ///布局MarkLine和MarkPoint
  void _onLayoutMarkPointAndLine(
      List<P> groupList, List<SingleNode<T, P>> newNodeList, Map<T, SingleNode<T, P>> newNodeMap) {
    if (series.markPoint == null &&
        series.markLine == null &&
        series.markPointFun == null &&
        series.markLineFun == null) {
      markLineList = [];
      markPointList = [];
      return;
    }
    final List<MarkPointNode> mpnl = [];
    final List<MarkLineNode> mlnl = [];
    for (var group in groupList) {
      if (group.data.isEmpty) {
        continue;
      }
      var mpl = series.getMarkPoint(group);
      var mll = series.getMarkLine(group);
      if (mpl.isEmpty && mll.isEmpty) {
        continue;
      }
      //markPoint
      for (var mp in mpl) {
        var node = onLayoutMarkPoint(mp, group, newNodeMap);
        if (node != null) {
          mpnl.add(node);
        }
      }
      //markLine
      for (var ml in mll) {
        var s = onLayoutMarkPoint(ml.start, group, newNodeMap);
        var e = onLayoutMarkPoint(ml.end, group, newNodeMap);
        if (s != null && e != null) {
          mlnl.add(MarkLineNode(ml, s, e));
        } else {
          if (s != null) {
            mpnl.add(s);
          }
          if (e != null) {
            mpnl.add(e);
          }
        }
      }
    }
    markPointList = mpnl;
    markLineList = mlnl;
  }

  MarkPointNode? onLayoutMarkPoint(MarkPoint markPoint, P group, Map<T, SingleNode<T, P>> newNodeMap) {
    var valueType = markPoint.data.valueType;
    if (markPoint.data.data != null) {
      var dl = markPoint.data.data!;
      if (dl.length < 2) {
        throw ChartError("in GridCoord or PolarCoord ,markPoint.data must is null or length >2");
      }
      var node = MarkPointNode(markPoint, dl[1]);
      if (coordSystem == CoordSystem.polar) {
        var position = findPolarCoord().dataToPosition(dl[0], dl[1]);
        var angle = (position.angle.first + position.angle.last) / 2;
        var radius = (position.radius.first + position.radius.last) / 2;
        node.offset = circlePoint(radius, angle, position.center);
      } else {
        var gridCoord = findGridCoord();
        List<Offset> xl = gridCoord.dataToPoint(group.xAxisIndex, dl[0], true);
        List<Offset> yl = gridCoord.dataToPoint(group.yAxisIndex, dl[1], false);
        double dx, dy;
        if (xl.length == 1) {
          dx = xl[0].dx;
        } else {
          var xAxis = gridCoord.getAxis(group.xAxisIndex, true);
          if (xAxis.isCategoryAxis && xAxis.categoryCenter) {
            dx = (xl[0].dx + xl[1].dx) / 2;
          } else {
            dx = xl[0].dx;
          }
        }
        if (yl.length == 1) {
          dy = yl[0].dy;
        } else {
          var yAxis = gridCoord.getAxis(group.yAxisIndex, false);
          if (yAxis.isCategoryAxis && yAxis.categoryCenter) {
            dy = (yl[0].dy + yl[1].dy) / 2;
          } else {
            dy = yl[0].dy;
          }
        }
        node.offset = Offset(dx, dy);
      }
      return node;
    }
    if (valueType != null) {
      var info = series.helper.getValueInfo(group);
      if (info == null) {
        return null;
      }
      T? data;
      if (valueType == ValueType.min && info.minData != null) {
        data = info.minData;
      } else if (valueType == ValueType.max && info.maxData != null) {
        data = info.maxData;
      } else if (valueType == ValueType.ave && info.aveData != null) {
        data = info.aveData;
      }
      SingleNode<T, P>? snode = newNodeMap[data];
      if (data == null || snode == null) {
        return null;
      }

      var node = MarkPointNode(markPoint, data.value);
      if (coordSystem == CoordSystem.polar) {
        var arc = snode.arc;
        node.offset = circlePoint(arc.outRadius, arc.centerAngle(), arc.center);
      } else {
        if (data.stackUp >= 0) {
          node.offset = snode.rect.topCenter;
        } else {
          node.offset = snode.rect.bottomCenter;
        }
      }
      return node;
    }
    final data = markPoint.data.coord;
    if (data != null) {
      bool vertical = series.direction == Direction.vertical;
      MarkPointNode node;
      if (coordSystem == CoordSystem.polar) {
        var coord = findPolarCoord();
        var radius = coord.getRadius();
        var x = data[0].convert(radius.last);
        var xr = x / radius.last;
        var y = data[1].convert(coord.getSweepAngle());
        var yr = y / coord.getSweepAngle();
        var dd = vertical ? coord.getScale(true).convertRatio(yr) : coord.getScale(false).convertRatio(xr);
        node = MarkPointNode(markPoint, dd);
        node.offset = Offset(x, y);
      } else {
        var coord = findGridCoord();
        final xIndex = group.xAxisIndex;
        final yIndex = group.yAxisIndex;
        var x = data[0].convert(coord.getAxisLength(xIndex, true));
        var xr = x / coord.getAxisLength(xIndex, true);
        var y = data[1].convert(coord.getAxisLength(yIndex, false));
        var yr = y / coord.getAxisLength(yIndex, false);
        var dd =
            vertical ? coord.getScale(yIndex, false).convertRatio(yr) : coord.getScale(xIndex, true).convertRatio(xr);
        node = MarkPointNode(markPoint, dd);
        node.offset = Offset(x, y);
      }
      return node;
    }

    return null;
  }

  ///由[onLayout]最后回调
  ///可以在这里进行动画相关的处理
  Future<void> onLayoutEnd(
    List<SingleNode<T, P>> oldNodeList,
    Map<T, SingleNode<T, P>> oldNodeMap,
    List<SingleNode<T, P>> newNodeList,
    Map<T, SingleNode<T, P>> newNodeMap,
    LayoutType type,
  ) async {
    if (!needRunAnimator(type)) {
      _nodeMap = newNodeMap;
      showNodeMap = Map.from(newNodeMap);
      return;
    }

    ///动画
    DiffResult2<SingleNode<T, P>, AnimatorNode, T> diffResult =
        DiffUtil.diff3(oldNodeList, newNodeList, (p0) => p0.data!, (b, c) {
      return onCreateAnimatorNode(b, c, type);
    });
    final startMap = diffResult.startMap;
    final endMap = diffResult.endMap;
    ChartDoubleTween doubleTween = ChartDoubleTween.fromValue(0, 1, props: series.animatorProps);
    doubleTween.startListener = () {
      Map<T, SingleNode<T, P>> sm = {};
      startMap.forEach((key, value) {
        if (key.data != null) {
          sm[key.data!] = key;
        }
      });
      _nodeMap = sm;
      showNodeMap = sm;
      onAnimatorStart(diffResult);
    };
    doubleTween.endListener = () {
      _nodeMap = newNodeMap;
      Map<T, SingleNode<T, P>> sm = {};
      startMap.forEach((key, value) {
        if (key.data != null) {
          sm[key.data!] = key;
        }
      });
      showNodeMap = sm;
      onAnimatorEnd(diffResult);
      notifyLayoutEnd();
    };
    doubleTween.addListener(() {
      double t = doubleTween.value;
      each(diffResult.startList, (node, p1) {
        onAnimatorUpdate(node, t, startMap, endMap);
      });
      onAnimatorUpdateEnd(diffResult, t);
      notifyLayoutUpdate();
    });
    doubleTween.start(context, type == LayoutType.update);
  }

  //========动画相关函数=====

  bool needRunAnimator(LayoutType type) {
    if (type == LayoutType.none || series.animation == null) {
      return false;
    }
    var animator = series.animation!;
    if (type == LayoutType.update && animator.updateDuration.inMilliseconds <= 0) {
      return false;
    }
    if (type == LayoutType.layout && animator.duration.inMilliseconds <= 0) {
      return false;
    }
    return true;
  }

  ///创建动画节点
  AnimatorNode onCreateAnimatorNode(SingleNode<T, P> node, DiffType diffType, LayoutType type);

  void onAnimatorStart(DiffResult2<SingleNode<T, P>, AnimatorNode, T> result) {}

  void onAnimatorUpdate(
    SingleNode<T, P> node,
    double t,
    Map<SingleNode<T, P>, AnimatorNode> startMap,
    Map<SingleNode<T, P>, AnimatorNode> endMap,
  ) {}

  void onAnimatorUpdateEnd(DiffResult2<SingleNode<T, P>, AnimatorNode, T> result, double t) {}

  void onAnimatorEnd(DiffResult2<SingleNode<T, P>, AnimatorNode, T> result) {}

  ///=======其它函数======
  List<dynamic> getAxisExtreme(S series, int axisIndex, bool isXAxis) {
    CoordSystem system = CoordSystem.grid;
    if (series.coordSystem == CoordSystem.polar) {
      system = CoordSystem.polar;
    }
    if (series.isVertical && !isXAxis || (!series.isVertical && isXAxis)) {
      return series.helper.getCrossExtreme(system, axisIndex);
    }
    return series.helper.getMainExtreme(system, axisIndex);
  }

  Offset getTranslation();

  ///==========用户相关操作的处理=============
  SingleNode<T, P>? oldHoverNode;

  @override
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
    if (node != null) {
      if (click) {
        sendClickEvent(offset, node.data, dataIndex: node.dataIndex, groupIndex: node.groupIndex);
      } else {
        sendHoverInEvent(offset, node.data, dataIndex: node.dataIndex, groupIndex: node.groupIndex);
      }
    }
    if (oldHoverNode != null && !click) {
      sendHoverInEvent(offset, oldHoverNode!.data,
          dataIndex: oldHoverNode!.dataIndex, groupIndex: oldHoverNode!.groupIndex);
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
      newAreStyleMap[node] = buildAreaStyle(node.data, node.parent, node.styleIndex, node.status);
      newLineStyleMap[node] = buildLineStyle(node.data, node.parent, node.styleIndex, node.status);
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

  @override
  void onHoverEnd() {
    if (oldHoverNode == null) {
      return;
    }
    onHandleHoverEnd(oldHoverNode, null);
  }

  @override
  void onBrushEvent(BrushEvent event) {
    nodeMap.forEach((key, node) {
      bool has = false;
      for (var area in event.data) {
        if (coordSystem == CoordSystem.grid && rectInPath(area.path, node.rect)) {
          has = true;
          break;
        }
        if (coordSystem == CoordSystem.polar && arcInPath(area.path, node.arc)) {
          has = true;
          break;
        }
      }
      if (has) {
        node.addState(ViewState.selected);
        node.removeState(ViewState.disabled);
      } else {
        node.removeState(ViewState.selected);
        node.addState(ViewState.disabled);
      }
    });
    notifyLayoutUpdate();
  }

  @override
  void onBrushEndEvent(BrushEndEvent event) {
    nodeMap.forEach((key, node) {
      bool has = false;
      for (var area in event.data) {
        if (coordSystem == CoordSystem.grid && rectInPath(area.path, node.rect)) {
          has = true;
          break;
        }
        if (coordSystem == CoordSystem.polar && arcInPath(area.path, node.arc)) {
          has = true;
          break;
        }
      }
      if (has) {
        node.addState(ViewState.selected);
      } else {
        node.removeState(ViewState.selected);
      }
    });
    notifyLayoutUpdate();
  }

  @override
  void onBrushClearEvent(BrushClearEvent event) {
    nodeMap.forEach((key, node) {
      node.removeState(ViewState.disabled);
      node.removeState(ViewState.selected);
    });
    notifyLayoutUpdate();
  }

  bool arcInPath(Path path, Arc arc) {
    Rect rect = path.getBounds();
    return rectInPath(arc.toPath(true), rect);
  }

  bool rectInPath(Path path, Rect rect) {
    if (path.contains(rect.topLeft)) {
      return true;
    }
    if (path.contains(rect.topRight)) {
      return true;
    }
    if (path.contains(rect.bottomLeft)) {
      return true;
    }
    if (path.contains(rect.bottomRight)) {
      return true;
    }

    Rect bound = path.getBounds();
    return bound.overlaps(rect);
  }

  CoordSystem get coordSystem;

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

  AreaStyle? buildAreaStyle(T? data, P group, int styleIndex, Set<ViewState>? status) {
    return series.getAreaStyle(context, data, group, styleIndex, status);
  }

  LineStyle? buildLineStyle(T? data, P group, int styleIndex, Set<ViewState>? status) {
    return series.getLineStyle(context, data, group, styleIndex, status);
  }
}
