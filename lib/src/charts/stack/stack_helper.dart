import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///用于处理堆叠数据的布局帮助者
///一般用于笛卡尔坐标系和极坐标系的布局
///需要支持部分布局
abstract class StackHelper<T extends StackItemData, P extends StackGroupData<T>, S extends StackSeries<T, P>>
    extends LayoutHelper2<SingleNode<T, P>, S> {
  List<MarkPointNode> markPointList = [];

  List<MarkLineNode> markLineList = [];

  StackHelper(super.context, super.view, super.series);

  @override
  void dispose() {
    markLineList = [];
    markPointList = [];
    super.dispose();
  }

  @override
  void doLayout(Rect boxBound, Rect globalBoxBound, LayoutType type) {
    subscribeBrushEvent();
    subscribeLegendEvent();
    super.doLayout(boxBound, globalBoxBound, type);
  }

  @override
  void onLayout(LayoutType type) {
    var animator = getAnimation(type);
    if (needRunAnimator(type) && animator != null) {
      onLayoutForAnimator(type, animator);
      return;
    }
    var helper = series.getHelper(context);

    //Dispose Old Node
    var oldList = nodeList;
    nodeList = [];
    each(oldList, (p0, p1) {
      p0.dispose();
    });

    List<SingleNode<T, P>> newNodeList = onComputeNeedLayoutData(helper);
    Set<GroupNode<T, P>> groupNodeSet = Set.from(newNodeList.map((e) => e.parentNode.parentNode));
    Map<AxisIndex, List<GroupNode<T, P>>> axisNodeMap = {};
    each(groupNodeSet, (groupNode, p1) {
      List<GroupNode<T, P>> groupList = axisNodeMap[groupNode.index] ?? [];
      axisNodeMap[groupNode.index] = groupList;
      groupList.add(groupNode);
    });

    ///对节点进行排序(同时也处理实时排序)
    axisNodeMap.forEach((key, vList) {
      vList.sort((a, b) {
        return a.groupIndex.compareTo(b.groupIndex);
      });
    });

    ///开始布局
    for (var ele in axisNodeMap.values) {
      ///布局Group
      for (var groupNode in ele) {
        if (groupNode.nodeList.isEmpty) {
          continue;
        }

        ///布局当前组的位置
        onLayoutGroup(groupNode, type);

        ///布局组里面的列
        onLayoutColumn(helper.result, groupNode, type);

        ///布局列里面的节点
        for (var cn in groupNode.nodeList) {
          onLayoutNode(cn, type);
        }
      }
    }
    each(newNodeList, (p0, p1) {
      p0.updateLabelPosition(context, series);
      p0.updateStyle(context, series);
    });
    layoutMarkPointAndLine(helper, series.data, newNodeList);
    nodeList = newNodeList;
  }

  void onLayoutForAnimator(LayoutType type, AnimatorOption animator) {
    var helper = series.getHelper(context);
    var oldNodeList = nodeList;

    Map<T, SingleNode<T, P>> oldNodeMap = {};
    each(oldNodeList, (p0, p1) {
      if (p0.originData != null) {
        oldNodeMap[p0.originData!] = p0;
      }
    });

    List<SingleNode<T, P>> newNodeList = onComputeNeedLayoutData(helper);
    newNodeList.removeWhere((element) => element.originData == null);

    Set<GroupNode<T, P>> groupNodeSet = Set.from(newNodeList.map((e) => e.parentNode.parentNode));
    Map<AxisIndex, List<GroupNode<T, P>>> axisNodeMap = {};
    each(groupNodeSet, (groupNode, p1) {
      List<GroupNode<T, P>> groupList = axisNodeMap[groupNode.index] ?? [];
      axisNodeMap[groupNode.index] = groupList;
      groupList.add(groupNode);
    });

    ///对节点进行排序(同时也处理实时排序)
    axisNodeMap.forEach((key, vList) {
      vList.sort((a, b) {
        return a.groupIndex.compareTo(b.groupIndex);
      });
    });

    var diffResult = _diffNode(oldNodeList, newNodeList);
    diffResult.removeSet.removeWhere((element) => element.originData == null);
    diffResult.addSet.removeWhere((element) => element.originData == null);
    diffResult.updateSet.removeWhere((element) => element.originData == null);

    Map<T, StackAnimatorNode> startMap = {};
    Map<T, StackAnimatorNode> endMap = {};

    each(diffResult.updateSet, (node, p1) {
      var data = node.originData!;
      var oldNode = oldNodeMap[data]!;
      startMap[data] = onCreateAnimatorNode(oldNode, DiffType.update, true);
    });
    each(diffResult.removeSet, (node, p1) {
      var data = node.originData!;
      startMap[data] = onCreateAnimatorNode(node, DiffType.remove, true);
    });

    ///开始布局
    for (var ele in axisNodeMap.values) {
      ///布局Group
      for (var groupNode in ele) {
        if (groupNode.nodeList.isEmpty) {
          continue;
        }

        ///布局当前组的位置
        onLayoutGroup(groupNode, type);

        ///布局组里面的列
        onLayoutColumn(helper.result, groupNode, type);

        ///布局列里面的节点
        for (var cn in groupNode.nodeList) {
          onLayoutNode(cn, type);
        }
      }
    }
    each(newNodeList, (p0, p1) {
      p0.updateLabelPosition(context, series);
      p0.updateStyle(context, series);
    });
    layoutMarkPointAndLine(helper, series.data, newNodeList);

    ///布局结束-准备动画
    ///对于add和update 在收集数据后需要还原到当前状态
    each(diffResult.addSet, (node, p1) {
      var data = node.originData!;
      startMap[data] = onCreateAnimatorNode(node, DiffType.add, true);
      endMap[data] = onCreateAnimatorNode(node, DiffType.add, false);

      ///还原初始位置
      onAnimatorUpdate(node, 0, startMap[data]!, endMap[data]!);
    });
    each(diffResult.updateSet, (node, p1) {
      var data = node.originData!;
      endMap[data] = onCreateAnimatorNode(node, DiffType.update, false);

      ///还原初始位置
      onAnimatorUpdate(node, 0, startMap[data]!, endMap[data]!);
    });
    each(diffResult.removeSet, (node, p1) {
      endMap[node.originData!] = onCreateAnimatorNode(node, DiffType.remove, false);
    });

    var tmpList = [...diffResult.removeSet, ...newNodeList];

    var removeTween = ChartDoubleTween(option: animator);
    removeTween.addListener(() {
      var t = removeTween.value;
      each(diffResult.removeSet, (node, p1) {
        var data = node.originData!;
        var s = startMap[data]!;
        var e = endMap[data]!;
        onAnimatorUpdate(node, t, s, e);
      });
      notifyLayoutUpdate();
    });
    removeTween.addEndListener(() {
      nodeList = newNodeList;
    });
    removeTween.addStartListener(() {
      onAnimatorStart(tmpList);
      nodeList=tmpList;
      notifyLayoutUpdate();
    });

    var addTween = ChartDoubleTween(option: animator);
    addTween.addListener(() {
      var t = addTween.value;
      each(diffResult.addSet, (node, p1) {
        var data = node.originData!;
        var s = startMap[data]!;
        var e = endMap[data]!;
        onAnimatorUpdate(node, t, s, e);
      });
      notifyLayoutUpdate();
    });
    var updateTween = ChartDoubleTween(option: animator);
    updateTween.addListener(() {
      var t = updateTween.value;
      each(diffResult.updateSet, (node, p1) {
        var data = node.originData!;
        var s = startMap[data]!;
        var e = endMap[data]!;
        onAnimatorUpdate(node, t, s, e);
      });
      notifyLayoutUpdate();
    });

    var endTween = removeTween;
    if (animator.duration.inMilliseconds > animator.updateDuration.inMilliseconds) {
      endTween = addTween;
    }
    endTween.addEndListener(() {
      onAnimatorEnd(newNodeList);
      nodeList=newNodeList;
      notifyLayoutUpdate();
    });
    context.addAnimationToQueue([
      AnimationNode(removeTween, animator, LayoutType.update),
      AnimationNode(addTween, animator, LayoutType.layout),
      AnimationNode(updateTween, animator, LayoutType.update),
    ]);
  }


  ///进行Diff比较，当为Update时使用新值
  DiffResult2<N> _diffNode<N>(Iterable<N> oldList, Iterable<N> newList) {
    Set<N> oldSet = Set.from(oldList);
    Set<N> newsSet = Set.from(newList);

    Set<N> addSet = {};
    Set<N> removeSet = {};
    Set<N> updateSet = {};

    for (var node in newList) {
      if (!oldSet.contains(node)) {
        addSet.add(node);
      } else {
        updateSet.add(node);
      }
    }

    for (var node in oldList) {
      if (!newsSet.contains(node)) {
        removeSet.add(node);
      }
    }
    return DiffResult2(addSet, removeSet, updateSet);
  }

  ///返回当前需要布局的数据
  List<SingleNode<T, P>> onComputeNeedLayoutData(DataHelper<T, P, StackSeries<T, P>> helper) {
    if (coordSystem != CoordType.grid) {
      return helper.nodeMap.values.toList();
    }

    List<SingleNode<T, P>> resultList = [];
    if (series.realtimeSort) {
      ///对于realtimeSort 其必须只能为一组数据
      resultList.addAll(helper.nodeMap.values);
      int sortCount = series.sortCount ?? 2 ^ 32 - 1;
      if (sortCount <= 0) {
        sortCount = 2 ^ 32 - 1;
      }
      if (resultList.length > sortCount) {
        resultList.removeRange(sortCount, resultList.length);
      }
      return resultList;
    }

    var coord = findGridCoord();
    Map<int, RangeInfo> infoMap = {};
    helper.result.storeMap.forEach((key, value) {
      var index = key.axisIndex;
      var info = infoMap[key.axisIndex] ?? coord.getAxisViewportDataRange(key.axisIndex, series.isVertical);
      infoMap[index] = info;
      resultList.addAll(value.getDataByRange(info));
    });
    return resultList;
  }

  ///实现该方法从而布局单个Group(不需要布局其孩子)
  void onLayoutGroup(GroupNode<T, P> groupNode, LayoutType type);

  ///布局GroupNode的孩子(ColumnNode)位置
  void onLayoutColumn(AxisGroup<T, P> axisGroup, GroupNode<T, P> groupNode, LayoutType type);

  ///布局ColumnNode的孩子的位置
  void onLayoutNode(ColumnNode<T, P> columnNode, LayoutType type);

  ///布局MarkLine和MarkPoint
  void layoutMarkPointAndLine(
      DataHelper<T, P, StackSeries<T, P>> helper, List<P> groupList, List<SingleNode<T, P>> newNodeList) {
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
        var node = onLayoutMarkPoint(helper, mp, group);
        if (node != null) {
          mpnl.add(node);
        }
      }
      //markLine
      for (var ml in mll) {
        var s = onLayoutMarkPoint(helper, ml.start, group);
        var e = onLayoutMarkPoint(helper, ml.end, group);
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
      layoutMarkPointAndLine(helper, series.data, nodeList);
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

  MarkPointNode? onLayoutMarkPoint(DataHelper<T, P, StackSeries<T, P>> helper, MarkPoint markPoint, P group) {
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
      var snode = helper.findNode(data);
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
  void onLayoutEnd(
    List<SingleNode<T, P>> oldNodeList,
    List<SingleNode<T, P>> newNodeList,
    Map<SingleNode<T, P>, StackAnimatorNode> startMap,
    Map<SingleNode<T, P>, StackAnimatorNode> endMap,
    LayoutType type,
  ) {
    var animation = getAnimation(type);
    if (!needRunAnimator(type) || animation == null) {
      nodeList = newNodeList;
      return;
    }

    ///动画
    var an = DiffUtil.diffLayout3<SingleNode<T, P>>(
      animation,
      oldNodeList,
      newNodeList,
      (node, diffType) => {'data': startMap[node]},
      (node, diffType) => {'data': endMap[node]},
      (node, s, e, t, type) {
        var sr = s['data'] as StackAnimatorNode;
        var er = e['data'] as StackAnimatorNode;
        onAnimatorUpdate(node, t, sr, er);
      },
      (resultList, t) {
        nodeList = resultList;
        onAnimatorUpdateEnd(resultList, t);
        notifyLayoutUpdate();
      },
      onEnd: () {
        nodeList = newNodeList;
        onAnimatorEnd(nodeList);
        notifyLayoutEnd();
      },
      onStart: () {
        onAnimatorStart(nodeList);
      },
    );
    context.addAnimationToQueue(an);
  }

  // void onLayoutEnd2(
  //     List<SingleNode<T, P>> oldNodeList,
  //     List<SingleNode<T, P>> newNodeList,
  //     Map<SingleNode<T, P>, StackAnimatorNode> startMap,
  //     Map<SingleNode<T, P>, StackAnimatorNode> endMap,
  //     LayoutType type,
  //     ) {
  //   var animation = getAnimation(type);
  //   if (!needRunAnimator(type) || animation == null) {
  //     nodeList = newNodeList;
  //     return;
  //   }
  //
  //   ///动画
  //   var an = DiffUtil.diffLayout3<SingleNode<T, P>>(
  //     animation,
  //     oldNodeList,
  //     newNodeList,
  //         (node, diffType) => {'data': startMap[node]},
  //         (node, diffType) => {'data': endMap[node]},
  //         (node, s, e, t, type) {
  //       var sr = s['data'] as StackAnimatorNode;
  //       var er = e['data'] as StackAnimatorNode;
  //       onAnimatorUpdate(node, t, sr, er);
  //     },
  //         (resultList, t) {
  //       nodeList = resultList;
  //       onAnimatorUpdateEnd(resultList, t);
  //       notifyLayoutUpdate();
  //     },
  //     onEnd: () {
  //       nodeList = newNodeList;
  //       onAnimatorEnd(nodeList);
  //       notifyLayoutEnd();
  //     },
  //     onStart: () {
  //       onAnimatorStart(nodeList);
  //     },
  //   );
  //   context.addAnimationToQueue(an);
  // }

  ///==============动画相关函数===============
  bool needRunAnimator(LayoutType type) {
    if (type == LayoutType.none) {
      return false;
    }
    return getAnimation(type) != null;
  }

  ///创建动画节点
  StackAnimatorNode onCreateAnimatorNode(SingleNode<T, P> node, DiffType diffType, bool isStart);

  void onAnimatorStart(List<SingleNode<T, P>> nodeList) {}

  void onAnimatorUpdate(SingleNode<T, P> node, double t, StackAnimatorNode startStatus, StackAnimatorNode endStatus) {
    var s = startStatus.rect;
    var e = endStatus.rect;
    if (s == null || e == null) {
      return;
    }
    node.rect = Rect.lerp(s, e, t)!;

    node.attr.position = node.rect.center;
    if (series.realtimeSort && series.dynamicLabel) {
      var axisIndex = series.isVertical ? node.parent.yAxisIndex : node.parent.xAxisIndex;
      var pos = series.isVertical ? node.rect.top : node.rect.right;
      var s = findGridCoord().pxToData(axisIndex, series.isHorizontal, pos);
      node.attr.dynamicLabel = s;
    } else {
      node.attr.dynamicLabel = null;
    }
    node.updateLabelPosition(context, series);
  }

  void onAnimatorUpdateEnd(List<SingleNode<T, P>> nodeList, double t) {}

  void onAnimatorEnd(List<SingleNode<T, P>> nodeList) {}

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
    each(nodeList, (value, i) {
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
    each(nodeList, (node, i) {
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
    if (data == null) {
      return null;
    }
    return series.getHelper(context).findNode(data);
  }

  @override
  SingleNode<T, P>? findNode(Offset offset, [bool overlap = false]) {
    for (var ele in nodeList) {
      if (ele.contains(offset)) {
        return ele;
      }
    }
    for (var ele in series.getHelper(context).nodeMap.values) {
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
