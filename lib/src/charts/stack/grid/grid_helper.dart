import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

///适用于GridCoord坐标系的布局帮助者
class GridHelper<T extends StackItemData, P extends StackGroupData<T>, S extends StackSeries<T, P>>
    extends StackHelper<T, P, S> {
  ///根据给定的页码编号，返回对应的数据
  GridHelper(super.context, super.view, super.series) {
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
  void onLayout(LayoutType type) {
    if (_tmpType != null) {
      type = _tmpType!;
      _tmpType = null;
    }
    super.onLayout(type);
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
    final bool vertical = series.direction == Direction.vertical;
    double l, r, t, b;
    if (vertical) {
      t = 0;
      b = height;
      l = xList.first.dx;
      r = xList.last.dx;
      if (xList.length == 1) {
        var type = coord.getAxisType(xIndex, true);
        if (type == AxisType.value || type == AxisType.log) {
          num d = l;
          var interval = coord.getScale(xIndex, true).tickInterval / 2;
          l = d - interval;
          r = d + interval;
        }
      }
      groupNode.rect = Rect.fromLTRB(l, t, r, b);
    } else {
      l = 0;
      r = width;
      t = yList.first.dy;
      b = yList.last.dy;
      if (b < t) {
        var tt = t;
        t = b;
        b = tt;
      }
      if (yList.length == 1) {
        var type = coord.getAxisType(yIndex, false);
        if (type == AxisType.value || type == AxisType.log) {
          num d = t;
          var interval = coord.getScale(yIndex, false).tickInterval / 2;
          t = d - interval;
          b = d + interval;
        }
      }
      groupNode.rect = Rect.fromLTRB(l, t, r, b);
    }
  }

  ///计算Column的位置，Column会占满一行或者一列
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
      if (vertical) {
        node.rect = Rect.fromLTRB(offset, groupRect.top, offset + sizeList[i], groupRect.bottom);
        offset += sizeList[i] + columnGap;
      } else {
        node.rect = Rect.fromLTRB(groupRect.left, offset, groupRect.right, offset + sizeList[i]);
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
      var upv = getUpValue(node);
      var dowv = getDownValue(node);
      // if (upv == null || dowv == null) {
      //   continue;
      // }
      final uo = coord.dataToPoint(index, upv, isX).last;
      final downo = coord.dataToPoint(index, dowv, isX).first;
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
    DiffResult2<SingleNode<T, P>, StackAnimationNode, T> diffResult =
        DiffUtil.diff(oldShowData, newNodeList, (p0) => p0.originData!, (b, c) {
      return onCreateAnimatorNode(b, c, type);
    });
    final startMap = diffResult.startMap;
    final endMap = diffResult.endMap;
    ChartDoubleTween doubleTween = ChartDoubleTween.fromValue(0, 1, option: series.animation!);
    doubleTween.addStartListener(() {
      Map<T, SingleNode<T, P>> map = {};
      diffResult.startMap.forEach((key, value) {
        if (key.originData != null) {
          map[key.originData!] = key;
        }
      });
      showNodeMap = map;
      updateNodeMap(map);
      onAnimatorStart(diffResult);
    });
    doubleTween.addEndListener(() {
      Map<T, SingleNode<T, P>> map = {};
      for (var value in diffResult.endList) {
        if (value.originData != null) {
          map[value.originData!] = value;
        }
      }
      showNodeMap = map;
      updateNodeMap(newNodeMap);
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
    doubleTween.start(context, type == LayoutType.update);
  }

  @override
  StackAnimationNode onCreateAnimatorNode(SingleNode<T, P> node, DiffType diffType, LayoutType type) {
    final Rect rect = node.rect;
    if (diffType == DiffType.update) {
      return StackAnimationNode(rect: rect, offset: rect.center);
    }

    Rect rr;
    if (series.isVertical) {
      if (series.realtimeSort && type == LayoutType.update) {
        Rect rr = Rect.fromLTRB(width, rect.top, width + rect.width, rect.bottom);
        return StackAnimationNode(rect: rr, offset: rr.center);
      }
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        rr = Rect.fromLTWH(rect.left, height, rect.width, 0);
      } else {
        rr = Rect.fromLTWH(rect.left, rect.bottom, rect.width, 0);
      }
      return StackAnimationNode(rect: rr, offset: rr.center);
    }

    ///水平
    if (series.realtimeSort && type == LayoutType.update) {
      rr = Rect.fromLTRB(0, height, width, height + rect.height);
      return StackAnimationNode(rect: rr, offset: rr.center);
    }
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      rr = Rect.fromLTWH(0, rect.top, 0, rect.height);
    } else {
      rr = Rect.fromLTWH(rect.left, rect.top, 0, rect.height);
    }
    return StackAnimationNode(rect: rr, offset: rr.center);
  }

  @override
  void onAnimatorUpdate(SingleNode<T, P> node, double t, var startMap, var endMap) {
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

  @override
  void onCoordScrollUpdate(CoordScroll scroll) {
    onLayout(LayoutType.none);
    if (!series.dynamicRange) {
      notifyLayoutUpdate();
      return;
    }
    findGridCoord().onAdjustAxisDataRange(AdjustAttr(!series.isVertical));
    notifyLayoutUpdate();
  }

  @override
  void onCoordScaleUpdate(CoordScale scale) {
    onLayout(LayoutType.none);
  }

  @override
  void onLayoutByParent(LayoutType type) {
    onLayout(type);
  }

  @override
  Offset getTranslation() {
    return findGridCoord().translation;
  }

  @override
  Offset getMaxTranslation() {
    return findGridCoord().getMaxScroll();
  }

  @override
  CoordType get coordSystem => CoordType.grid;
}
