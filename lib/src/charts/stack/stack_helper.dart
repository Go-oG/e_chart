import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///用于处理堆叠数据的布局帮助者
///一般用于笛卡尔坐标系和极坐标系的布局
///需要支持部分布局
abstract class StackHelper<T extends StackItemData, P extends StackGroupData<T>, S extends StackSeries<T, P>>
    extends LayoutHelper2<SingleNode<T, P>, S> {
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

  ///标识需要进行二次布局
  bool needSecondDynamicLayout = false;

  StackHelper(super.context, super.view, super.series) {
    needSecondDynamicLayout = series.dynamicRange;
  }

  @override
  void dispose() {
    showNodeMap = {};
    markLineList = [];
    markPointList = [];
    _nodeMap = {};
    super.dispose();
  }

  @override
  void doLayout(Rect boxBound, Rect globalBoxBound, LayoutType type) {
    subscribeBrushEvent();
    subscribeLegendEvent();
    super.doLayout(boxBound, globalBoxBound, type);
    if (needSecondDynamicLayout) {
      needSecondDynamicLayout = false;
      onLayout(LayoutType.none);
    }
  }

  @override
  void onLayout(LayoutType type) {
    var helper = series.getHelper(context);
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
            if (node.originData == null) {
              continue;
            }
            newNodeMap[node.originData!] = node;
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
          if (groupNode.nodeList.isEmpty) {
            return;
          }

          ///布局当前组的位置
          onLayoutGroup(groupNode, type);

          ///布局组里面的列
          onLayoutColumn(axisGroup, groupNode, type);

          ///布局列里面的节点
          for (var cn in groupNode.nodeList) {
            onLayoutNode(cn, type);
          }
        }
      }
    });

    List<SingleNode<T, P>> oldNodeList = List.from(_nodeMap.values);
    var oldNodeMap = _nodeMap;
    final List<SingleNode<T, P>> newNodeList = List.from(newNodeMap.values, growable: false);

    each(newNodeList, (p0, p1) {
      p0.updateLabelPosition(context, series);
      p0.updateStyle(context, series);
    });

    layoutMarkPointAndLine(series.data, newNodeList, newNodeMap);
    onLayoutEnd(oldNodeList, oldNodeMap, newNodeList, newNodeMap, type);
  }

  ///计算需要布局的数据(默认全部)
  ///子类可以实现该方法从而实现高效的数据刷新
  List<GroupNode<T, P>> onComputeNeedLayoutData(
      DataHelper<T, P, StackSeries<T, P>> helper, AxisIndex index, List<GroupNode<T, P>> list) {
    return list;
  }

  bool needLayoutForNode(SingleNode<T, P> node, LayoutType type) {
    if (type != LayoutType.none) {
      return true;
    }
    return showNodeMap[node.originData!] == null || node.attr.rect.isEmpty;
  }

  ///实现该方法从而布局单个Group(不需要布局其孩子)
  void onLayoutGroup(GroupNode<T, P> groupNode, LayoutType type);

  ///布局GroupNode的孩子(ColumnNode)位置
  void onLayoutColumn(AxisGroup<T, P> axisGroup, GroupNode<T, P> groupNode, LayoutType type);

  ///布局ColumnNode的孩子的位置
  void onLayoutNode(ColumnNode<T, P> columnNode, LayoutType type);

  ///布局MarkLine和MarkPoint
  void layoutMarkPointAndLine(
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

    void hc() {
      layoutMarkPointAndLine(series.data, nodeList, nodeMap);
    }

    for (var mpn in mpnl) {
      mpn.markPoint.addListener(hc);
    }
    for (var mln in mlnl) {
      mln.line.addListener(hc);
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
      if (coordSystem == CoordType.polar) {
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
      var info = series.getHelper(context).getValueInfo(group);
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
      var snode = newNodeMap[data];
      if (data == null || snode == null) {
        return null;
      }

      var node = MarkPointNode(markPoint, data);
      if (coordSystem == CoordType.polar) {
        var arc = snode.attr.arc;
        node.offset = circlePoint(arc.outRadius, arc.centerAngle(), arc.center);
      } else {
        if (snode.up >= 0) {
          node.offset = snode.attr.rect.topCenter;
        } else {
          node.offset = snode.attr.rect.bottomCenter;
        }
      }
      return node;
    }
    final data = markPoint.data.coord;
    if (data != null) {
      bool vertical = series.direction == Direction.vertical;
      MarkPointNode node;
      if (coordSystem == CoordType.polar) {
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
  void onLayoutEnd(List<SingleNode<T, P>> oldNodeList, Map<T, SingleNode<T, P>> oldNodeMap,
      List<SingleNode<T, P>> newNodeList, Map<T, SingleNode<T, P>> newNodeMap, LayoutType type) {
    var animation = getAnimation(type);
    if (!needRunAnimator(type) || animation == null) {
      _nodeMap = newNodeMap;
      showNodeMap = Map.from(newNodeMap);
      return;
    }

    ///动画
    DiffResult<SingleNode<T, P>, StackAnimationNode, T> diffResult =
        DiffUtil.diff(oldNodeList, newNodeList, (p0) => p0.originData!, (b, c) {
      return onCreateAnimatorNode(b, c, type);
    });
    final startMap = diffResult.startMap;
    final endMap = diffResult.endMap;
    ChartDoubleTween doubleTween = ChartDoubleTween.fromValue(0, 1, option: animation);
    doubleTween.addStartListener(() {
      Map<T, SingleNode<T, P>> sm = {};
      startMap.forEach((key, value) {
        if (key.originData != null) {
          sm[key.originData!] = key;
        }
      });
      _nodeMap = sm;
      showNodeMap = sm;
      onAnimatorStart(diffResult);
    });
    doubleTween.addEndListener(() {
      _nodeMap = newNodeMap;
      Map<T, SingleNode<T, P>> sm = {};
      startMap.forEach((key, value) {
        if (key.originData != null) {
          sm[key.originData!] = key;
        }
      });
      showNodeMap = sm;
      onAnimatorEnd(diffResult);
      notifyLayoutEnd();
    });
    doubleTween.addListener(() {
      double t = doubleTween.value;
      each(diffResult.startList, (node, p1) {
        onAnimatorUpdate(node, t, startMap, endMap);
      });
      onAnimatorUpdateEnd(diffResult, t);
      notifyLayoutUpdate();
    });
    context.addAnimationToQueue([AnimationNode(doubleTween, animation, type)]);
  }

  ///==============动画相关函数===============
  bool needRunAnimator(LayoutType type) {
    if (type == LayoutType.none) {
      return false;
    }
    return getAnimation(type) != null;
  }


  ///创建动画节点
  StackAnimationNode onCreateAnimatorNode(SingleNode<T, P> node, DiffType diffType, LayoutType type);

  void onAnimatorStart(DiffResult<SingleNode<T, P>, StackAnimationNode, T> result) {}

  void onAnimatorUpdate(SingleNode<T, P> node, double t, Map<SingleNode<T, P>, StackAnimationNode> startMap,
      Map<SingleNode<T, P>, StackAnimationNode> endMap) {
    var s = startMap[node]!.rect;
    var e = endMap[node]!.rect;
    if (s == null || e == null) {
      return;
    }
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      node.rect = Rect.lerp(s, e, t)!;
    } else {
      if (series.isVertical) {
        node.rect = Rect.fromLTRB(e.left, e.bottom - e.height * t, e.right, e.bottom);
      } else {
        node.rect = Rect.fromLTWH(e.left, e.top, e.width * t, e.height);
      }
    }

    if (series.realtimeSort && series.dynamicLabel) {
      var axisIndex = series.isVertical ? node.parent.yAxisIndex : node.parent.xAxisIndex;
      node.attr.dynamicLabel =
          findGridCoord().pxToData(axisIndex, !series.isVertical, series.isVertical ? node.rect.top : node.rect.right);
    } else {
      node.attr.dynamicLabel = null;
    }
    node.updateLabelPosition(context, series);
  }

  void onAnimatorUpdateEnd(DiffResult<SingleNode<T, P>, StackAnimationNode, T> result, double t) {}

  void onAnimatorEnd(DiffResult<SingleNode<T, P>, StackAnimationNode, T> result) {}

  //===========动画结束=========

  dynamic getNodeUpValue(SingleNode<T, P> node) {
    return node.up;
  }

  dynamic getNodeDownValue(SingleNode<T, P> node) {
    return node.down;
  }

  ///=======其它函数======
  ///获取指定坐标轴上的极值数据
  List<dynamic> getAxisExtreme(int axisIndex, bool isXAxis) {
    CoordType system = CoordType.grid;
    if (series.coordType == CoordType.polar) {
      system = CoordType.polar;
    }
    AxisType type;
    if (series.coordType == CoordType.polar) {
      var coord = findPolarCoord();
      type = isXAxis ? coord.radiusAxisType : coord.angleAxisType;
    } else {
      var coord = findGridCoord();
      type = coord.getAxisType(axisIndex, isXAxis);
    }
    var extreme = series.getHelper(context).getExtreme(system, isXAxis, axisIndex);
    if (type == AxisType.category) {
      return extreme.strExtreme;
    }
    if (type == AxisType.time) {
      return extreme.timeExtreme;
    }
    return extreme.numExtreme;
  }

  ///获取当前显示窗口内的极值数据
  List<dynamic> getViewPortAxisExtreme(int axisIndex, bool isXAxis, BaseScale scale) {
    List<dynamic> dl = [];
    showNodeMap.forEach((key, value) {
      if (value.originData == null) {
        return;
      }
      var index = isXAxis ? value.parent.xAxisIndex : value.parent.yAxisIndex;
      if (index < 0) {
        index = 0;
      }
      if (index != axisIndex) {
        return;
      }
      if (series.isVertical && !isXAxis || (!series.isVertical && isXAxis)) {
        dl.add(value.originData!.minValue);
        dl.add(value.originData!.maxValue);
      } else {
        if (isXAxis) {
          dl.add(value.originData!.x);
        } else {
          dl.add(value.originData!.y);
        }
      }
    });
    return dl;
  }

  ///==========Brush相关的=============

  @override
  void onBrushUpdate(BrushUpdateEvent event) {
    onHandleBrush(event.areas);
  }

  @override
  void onBrushEnd(BrushEndEvent event) {
    onHandleBrush(event.areas);
  }

  void onHandleBrush(List<BrushArea> areas) {
    nodeMap.forEach((key, node) {
      bool has = false;
      for (var area in areas) {
        if (coordSystem == CoordType.grid && area.path.overlapRect(node.rect)) {
          has = true;
          break;
        }
        if (coordSystem == CoordType.polar && node.attr.arc.toPath().overlapRect(area.bounds)) {
          has = true;
          break;
        }
      }
      if (has) {
        has = node.updateStatus(context, [ViewState.disabled], [ViewState.selected]);
      } else {
        has = node.updateStatus(context, [ViewState.selected], [ViewState.disabled]);
      }
      if (has) {
        node.updateStyle(context, series);
      }
    });
    notifyLayoutUpdate();
  }

  CoordType get coordSystem;

  @override
  SingleNode<T, P>? findNodeByData(covariant T? data) {
    return nodeMap[data];
  }

  @override
  SingleNode<T, P>? findNode(Offset offset, [bool overlap = false]) {
    for (var ele in showNodeMap.values) {
      if (ele.contains(offset)) {
        return ele;
      }
    }
    for (var ele in nodeMap.values) {
      if (ele.contains(offset)) {
        return ele;
      }
    }
    return null;
  }

  @override
  Offset getTranslation() {
    var type = coordSystem;
    if (type == CoordType.polar) {
      return findPolarCoord().translation;
    }
    return findGridCoord().translation;
  }

  Offset getMaxTranslation() {
    var type = coordSystem;
    if (type == CoordType.polar) {
      return findPolarCoord().getMaxScroll();
    }
    return findGridCoord().getMaxScroll();
  }
}
