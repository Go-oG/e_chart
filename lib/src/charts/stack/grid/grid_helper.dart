import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';

///适用于GridCoord坐标系的布局帮助者
class GridHelper<T extends StackItemData, P extends StackGroupData<T,P>, S extends StackSeries<T, P>>
    extends StackHelper<T, P, S> {
  ///根据给定的页码编号，返回对应的数据
  GridHelper(super.context, super.view, super.series);

  @override
  void onSeriesDataUpdate() {
    findGridCoord().onChildDataSetChange(true);
    notifyLayoutUpdate();
  }

  @override
  void doLayout(Rect boxBound, Rect globalBoxBound, LayoutType type) {
    subscribeAxisScrollEvent();
    subscribeAxisChangeEvent();
    super.doLayout(boxBound, globalBoxBound, type);
  }

  @override
  void onLayoutGroup(GroupNode<T, P> groupNode, LayoutType type) {
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
  void onLayoutColumn(var axisGroup, var groupNode, LayoutType type) {
    final int groupInnerCount = axisGroup.getColumnCount(AxisIndex(CoordType.grid, groupNode.getXAxisIndex()));
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
  void onLayoutNode(ColumnNode<T, P> columnNode, LayoutType type) {
    final bool vertical = series.direction == Direction.vertical;
    final coord = findGridCoord();
    final colRect = columnNode.rect;
    for (var node in columnNode.nodeList) {
      bool isX = !series.isVertical;
      int index = series.isVertical ? node.parent.yAxisIndex : node.parent.xAxisIndex;
      var upv = getNodeUpValue(node);
      var dowv = getNodeDownValue(node);
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

  @override
  void onAxisChange(AxisChangeEvent event) {
    if (event.coordType != CoordType.grid) {
      return;
    }
    if (event.coordViewId != findGridCoord().id) {
      return;
    }

    ///坐标轴发生更新 只需要更新当前显示数据的坐标
  }

  @override
  void onAxisScroll(AxisScrollEvent event) {
    if (event.coordType != CoordType.grid) {
      return;
    }
    if (event.coordViewId != findGridCoord().id) {
      return;
    }
    if (event.direction == null) {
      throw ChartError('缺失滚动方向');
    }
    bool xAxis = event.direction == Direction.vertical;
    if (event.direction == Direction.horizontal) {
      translationX = event.scrollOffset;
    } else {
      translationY = event.scrollOffset;
    }
    onLayout(LayoutType.none);
    if (series.dynamicRange) {
      findGridCoord().onRelayoutAxisByChild(xAxis, false);
    }
    notifyLayoutUpdate();
  }

  @override
  StackAnimatorNode onCreateAnimatorNode(StackData<T, P> node, DiffType diffType, bool isStart) {
    Rect rect = node.rect;
    if (diffType == DiffType.update ||
        (diffType == DiffType.remove && isStart) ||
        (diffType == DiffType.add && !isStart)) {
      return StackAnimatorNode(rect: node.attr.rect, offset: rect.center);
    }

    if (isStart) {
      ///add
      Rect rr;
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        rr = series.isVertical
            ? Rect.fromLTWH(rect.left, height, rect.width, 0)
            : Rect.fromLTWH(0, rect.top, 0, rect.height);
      } else {
        rr = series.isVertical
            ? Rect.fromLTWH(rect.left, rect.bottom, rect.width, 0)
            : Rect.fromLTWH(rect.left, rect.top, 0, rect.height);
      }
      return StackAnimatorNode(rect: rr, offset: rr.center);
    }

    //remove(当移除时动画样式固定为改变高度和宽度)
    Rect rr = series.isVertical
        ? Rect.fromLTWH(rect.left, rect.bottom, rect.width, 0)
        : Rect.fromLTWH(rect.left, rect.top, 0, rect.height);
    return StackAnimatorNode(rect: rr, offset: rr.center);
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
