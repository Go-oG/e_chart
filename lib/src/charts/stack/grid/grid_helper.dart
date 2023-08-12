import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

///适用于GridCoord坐标系的布局帮助者
abstract class GridHelper<T extends StackItemData, P extends StackGroupData<T>, S extends StackSeries<T, P>>
    extends StackHelper<T, P, S> {
  ///根据给定的页码编号，返回对应的数据
  GridHelper(super.context, super.series) {
    series.addListener(handleCommand);
  }

  @override
  void dispose() {
    series.removeListener(handleCommand);
    super.dispose();
  }

  void handleCommand() {
    var c = series.value;
    if (c.code == Command.updateData.code) {
      handleDataUpdate();
    }
  }

  LayoutType? _tmpType;

  void handleDataUpdate() {
    if (series.realtimeSort) {
      _tmpType = LayoutType.update;
    } else {
      _tmpType = LayoutType.none;
    }
    findGridCoord().onChildDataSetChange(true);
  }

  @override
  void onLayout(List<P> data, LayoutType type) {
    if (_tmpType != null) {
      type = _tmpType!;
      _tmpType = null;
    }
    super.onLayout(data, type);
  }

  @override
  List<GroupNode<T, P>> onComputeNeedLayoutData(var helper, AxisIndex index, List<GroupNode<T, P>> list) {
    ///启用了实时排序
    if (series.realtimeSort) {
      int sortCount = series.sortCount ?? 2 ^ 32 - 1;
      Set<ColumnNode<T, P>> colNodeSet = {};
      ColumnNode<T, P>? minNode;
      each(list, (gn, i) {
        if (gn.nodeList.length >= 2) {
          throw ChartError('if enable realtimeSort, stack Column must <=1');
        }
        var cl = gn.nodeList.first;
        if (cl.nodeList.isEmpty) {
          return;
        }
        if (colNodeSet.length < sortCount) {
          colNodeSet.add(cl);
          minNode = cl;
        } else {
          var up = cl.getUp();
          if (up > minNode!.getUp()) {
            colNodeSet.remove(minNode!);
            colNodeSet.add(cl);
            minNode = cl;
          }
        }
      });
      List<ColumnNode<T, P>> colNodeList = List.from(colNodeSet);
      colNodeList.sort((a, b) {
        var au = a.getUp();
        var bu = b.getUp();
        if (series.sort == Sort.asc) {
          return bu.compareTo(au);
        } else {
          return au.compareTo(bu);
        }
      });
      List<GroupNode<T, P>> rl = [];
      each(colNodeList, (e, i) {
        e.parentNode.nodeIndex = i;
        rl.add(e.parentNode);
      });
      return List.from(colNodeList.map((e) => e.parentNode));
    }
    var store = helper.result.storeMap[index];
    if (store == null) {
      Logger.i("Store is empty");
      return [];
    }
    var coord = findGridCoord();
    var rangeValue = coord.getViewportDataRange(index.axisIndex, series.isVertical);
    List<List<SingleNode<T, P>>> nodeList = [];
    if (rangeValue.categoryList != null) {
      nodeList = store.getByStr(rangeValue.categoryList!);
    } else if (rangeValue.timeList != null) {
      nodeList = store.getByTime(rangeValue.timeList!);
    } else if (rangeValue.numRange != null) {
      nodeList = store.getByNum(rangeValue.numRange!.start, rangeValue.numRange!.end);
    }
    Set<GroupNode<T, P>> gs = {};
    List<GroupNode<T, P>> ls = [];
    for (var pl in nodeList) {
      for (var node in pl) {
        var pn = node.parentNode.parentNode;
        if (gs.contains(pn)) {
          continue;
        }
        gs.add(pn);
        ls.add(pn);
      }
    }
    ls.sort((a, b) {
      return a.nodeIndex.compareTo(b.nodeIndex);
    });
    return ls;
  }

  @override
  void onLayoutGroup(GroupNode<T, P> groupNode, AxisIndex xIndex, dynamic x, LayoutType type) {
    var coord = findGridCoord();
    int yIndex = groupNode.getYAxisIndex();
    int xIndex = groupNode.getXAxisIndex();
    final xData = groupNode.getXData();
    final yData = groupNode.getYData();
    List<Offset> xList = coord.dataToPoint(xIndex, xData, true);
    List<Offset> yList = coord.dataToPoint(yIndex, yData, false);
    if (xList.length >= 2 && yList.length >= 2) {
      throw ChartError('内部布局状态异常');
    }
    double l, r, t, b;
    if (xList.length >= 2) {
      l = xList.first.dx;
      r = xList.last.dx;
      if (l > r) {
        var tt = l;
        l = r;
        r = tt;
      }
      t = 0;
      b = height;
    } else {
      t = yList.first.dy;
      b = yList.last.dy;
      if (b < t) {
        var tt = t;
        t = b;
        b = tt;
      }
      l = 0;
      r = width;
    }
    groupNode.rect = Rect.fromLTRB(l, t, r, b);
  }

  @override
  void onLayoutColumn(var axisGroup, var groupNode, AxisIndex xIndex, dynamic x, LayoutType type) {
    final int groupInnerCount = axisGroup.getColumnCount(xIndex);

    int colGapCount = groupInnerCount - 1;
    if (colGapCount < 1) {
      colGapCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;
    final Rect groupRect = groupNode.rect;
    final num groupSize = vertical ? groupRect.width : groupRect.height;

    double groupGap = series.groupGap.convert(groupSize) * 2;
    double columnGap = series.columnGap.convert(groupSize);
    double allGap = groupGap + colGapCount * columnGap;
    double canUseSize = groupSize - allGap;
    if (canUseSize < 0) {
      canUseSize = groupSize.toDouble();
    }
    double allBarSize = 0;

    ///计算Group占用的大小
    List<double> sizeList = [];
    each(groupNode.nodeList, (node, i) {
      var first = node.nodeList.first;
      var groupData = first.parent;
      double tmpSize;
      if (groupData.barSize != null) {
        tmpSize = groupData.barSize!.convert(canUseSize);
      } else {
        tmpSize = canUseSize / groupInnerCount;
        if (groupData.barMaxSize != null) {
          var s = groupData.barMaxSize!.convert(canUseSize);
          if (tmpSize > s) {
            tmpSize = s;
          }
        }
        if (groupData.barMinSize != null) {
          var size = groupData.barMinSize!.convert(canUseSize);
          if (tmpSize < size) {
            tmpSize = size;
          }
        }
      }
      allBarSize += tmpSize;
      sizeList.add(tmpSize);
    });

    if (allBarSize + allGap > groupSize) {
      double k = groupSize / (allBarSize + allGap);
      groupGap *= k;
      columnGap *= k;
      allBarSize *= k;
      allGap *= k;
      for (int i = 0; i < sizeList.length; i++) {
        sizeList[i] = sizeList[i] * k;
      }
    }
    double offset = vertical ? groupRect.left : groupRect.top;
    offset += groupGap * 0.5;
    each(groupNode.nodeList, (node, i) {
      if (node.nodeList.isEmpty) {
        return;
      }
      var parent = node.nodeList.first.parent;
      int yIndex = parent.yAxisIndex;
      var coord = findGridCoord();
      var upNode = node.getUpNode();
      var downNode = node.getDownNode();
      if (upNode == null || downNode == null) {
        Logger.w("内部状态异常 无法找到 upValue 或者downValue");
        return;
      }
      dynamic upValue = getUpValue(upNode), downValue = getDownValue(downNode);
      if (vertical) {
        var uo = coord.dataToPoint(yIndex, upValue, false).last;
        var downo = coord.dataToPoint(yIndex, downValue, false).first;
        node.rect = Rect.fromLTRB(offset, uo.dy, offset + sizeList[i], downo.dy);
        offset += sizeList[i] + columnGap;
      } else {
        var axisIndex = node.parentNode.getXAxisIndex();
        var lo = coord.dataToPoint(axisIndex, downValue, true).first;
        var ro = coord.dataToPoint(axisIndex, upValue, true).last;
        node.rect = Rect.fromLTRB(lo.dx, offset, ro.dx, offset + sizeList[i]);
        offset += sizeList[i] + columnGap;
      }
    });
  }

  @override
  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex, LayoutType type) {
    final bool vertical = series.direction == Direction.vertical;
    final coord = findGridCoord();
    final colRect = columnNode.rect;
    for (var node in columnNode.nodeList) {
      if (!needLayoutForNode(node, type)) {
        continue;
      }
      bool isX = !series.isVertical;
      int index = series.isVertical ? node.parent.yAxisIndex : node.parent.xAxisIndex;
      final uo = coord.dataToPoint(index, getUpValue(node), isX).last;
      final downo = coord.dataToPoint(index, getDownValue(node), isX).first;
      if (vertical) {
        node.rect = Rect.fromLTRB(colRect.left, uo.dy, colRect.right, downo.dy);
      } else {
        node.rect = Rect.fromLTRB(downo.dx, colRect.top, uo.dx, colRect.bottom);
      }
      node.position = node.rect.center;
    }
  }

  dynamic getUpValue(SingleNode<T, P> node) {
    return node.up;
  }

  dynamic getDownValue(SingleNode<T, P> node) {
    return node.down;
  }

  @override
  void onLayoutEnd(var oldNodeList, var oldNodeMap, var newNodeList, var newNodeMap, LayoutType type) {
    if (oldNodeList.isEmpty && newNodeList.isEmpty) {
      return;
    }

    if (!needRunAnimator(type)) {
      super.onLayoutEnd(oldNodeList, oldNodeMap, newNodeList, newNodeMap, type);
      return;
    }

    List<SingleNode<T, P>> oldShowData = List.from(showNodeMap.values);

    ///动画
    DiffResult2<SingleNode<T, P>, AnimatorNode, T> diffResult =
        DiffUtil.diff3(oldShowData, newNodeList, (p0) => p0.data!, (b, c) {
      return onCreateAnimatorNode(b, c, type);
    });
    final startMap = diffResult.startMap;
    final endMap = diffResult.endMap;
    ChartDoubleTween doubleTween = ChartDoubleTween.fromValue(0, 1, props: series.animatorProps);
    doubleTween.startListener = () {
      Map<T, SingleNode<T, P>> map = {};
      diffResult.startMap.forEach((key, value) {
        if (key.data != null) {
          map[key.data!] = key;
        }
      });
      showNodeMap = map;
      updateNodeMap(map);
      onAnimatorStart(diffResult);
    };
    doubleTween.endListener = () {
      Map<T, SingleNode<T, P>> map = {};
      for (var value in diffResult.endList) {
        if (value.data != null) {
          map[value.data!] = value;
        }
      }
      showNodeMap = map;
      updateNodeMap(newNodeMap);
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

  @override
  AnimatorNode onCreateAnimatorNode(SingleNode<T, P> node, DiffType diffType, LayoutType type) {
    final Rect rect = node.rect;
    if (diffType == DiffType.accessor) {
      return AnimatorNode(rect: rect, offset: rect.center);
    }

    Rect rr;
    if (series.isVertical) {
      if (series.realtimeSort && type == LayoutType.update) {
        Rect rr = Rect.fromLTRB(width, rect.top, width + rect.width, rect.bottom);
        return AnimatorNode(rect: rr, offset: rr.center);
      }
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        rr = Rect.fromLTWH(rect.left, height, rect.width, 0);
      } else {
        rr = Rect.fromLTWH(rect.left, rect.bottom, rect.width, 0);
      }
      return AnimatorNode(rect: rr, offset: rr.center);
    }

    ///水平
    if (series.realtimeSort && type == LayoutType.update) {
      rr = Rect.fromLTRB(0, height, width, height + rect.height);
      return AnimatorNode(rect: rr, offset: rr.center);
    }
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      rr = Rect.fromLTWH(0, rect.top, 0, rect.height);
    } else {
      rr = Rect.fromLTWH(rect.left, rect.top, 0, rect.height);
    }
    return AnimatorNode(rect: rr, offset: rr.center);
  }

  @override
  void onAnimatorUpdate(SingleNode<T, P> node, double t, var startMap, var endMap) {
    var s = startMap[node]!.rect;
    var e = endMap[node]!.rect;
    if (s == null || e == null) {
      return;
    }
    Rect r;
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      r = Rect.lerp(s, e, t)!;
    } else {
      if (series.isVertical) {
        r = Rect.fromLTRB(e.left, e.bottom - e.height * t, e.right, e.bottom);
      } else {
        r = Rect.fromLTWH(e.left, e.top, e.width * t, e.height);
      }
    }
    if (series.realtimeSort && series.dynamicLabel) {
      var axisIndex = series.isVertical ? node.parent.yAxisIndex : node.parent.xAxisIndex;
      node.dynamicLabel = findGridCoord().pxToData(axisIndex, !series.isVertical, series.isVertical ? r.top : r.right);
    } else {
      node.dynamicLabel = null;
    }
    node.rect = r;
  }

  @override
  void onContentScrollChange(Offset offset) {
    onLayout(series.data, LayoutType.none);
    if (!series.dynamicRange) {
      return;
    }
    if (series.isVertical) {
      findGridCoord().onAdjustAxisDataRange(AdjustAttr(false));
    } else {
      findGridCoord().onAdjustAxisDataRange(AdjustAttr(true));
    }
  }

  @override
  void onContentScaleUpdate(double sx, double sy) {
    onLayout(series.data, LayoutType.none);
  }

  @override
  void onLayoutByParent(LayoutType type) {
    onLayout(series.data, type);
  }

  @override
  SingleNode<T, P>? findNode(Offset offset) {
    for (var ele in showNodeMap.values) {
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

  @override
  Offset getMaxTranslation() {
    return findGridCoord().getMaxTranslation();
  }

  @override
  CoordSystem get coordSystem => CoordSystem.grid;
}
