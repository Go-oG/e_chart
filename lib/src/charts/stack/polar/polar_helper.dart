import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

///帮助在极坐标系中进行布局
abstract class PolarHelper<T extends StackItemData, P extends StackGroupData<T>, S extends StackSeries<T, P>>
    extends StackHelper<T, P, S> {
  PolarHelper(super.context, super.view, super.series);

  @override
  void onLayoutGroup(GroupNode<T, P> groupNode, AxisIndex xIndex, dynamic x, LayoutType type) {
    var coord = findPolarCoord();
    final xData = groupNode.getXData();
    final yData = groupNode.getYData();
    var position = coord.dataToPosition(xData,yData);
    num ir = position.radius.length == 1 ? 0 : position.radius[0];
    num or = position.radius.length == 1 ? position.radius[0] : position.radius[1];
    num sa = position.angle.length < 2 ? coord.getStartAngle() : position.angle[0];
    num ea = position.angle.length >= 2 ? position.angle[1] : position.angle[0];
    groupNode.arc = Arc(center: position.center, innerRadius: ir, outRadius: or, startAngle: sa, sweepAngle: ea - sa);
  }

  @override
  void onLayoutColumn(var axisGroup, var groupNode, AxisIndex xIndex, dynamic x, LayoutType type) {
    final int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int colGapCount = groupInnerCount - 1;
    if (colGapCount <= 1) {
      colGapCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;
    final Arc groupArc = groupNode.arc;
    final num groupSize = vertical ? (groupArc.outRadius - groupArc.innerRadius).abs() : groupArc.sweepAngle.abs();
    final int dir = groupArc.sweepAngle >= 0 ? 1 : -1;
    num groupGap = series.groupGap.convert(groupSize);
    num columnGap = series.columnGap.convert(groupSize);
    num allGap = groupGap * 2 + colGapCount * columnGap;
    num canUseSize = groupSize - allGap;
    if (canUseSize <= 0) {
      canUseSize = groupSize;
    }
    num allBarSize = 0;

    ///计算Group占用的大小
    List<num> sizeList = [];
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
      final double k = groupSize / (allBarSize + allGap);
      groupGap *= k;
      columnGap *= k;
      allBarSize *= k;
      allGap *= k;
      for (int i = 0; i < sizeList.length; i++) {
        sizeList[i] = sizeList[i] * k;
      }
    } else {
      num tmp = groupSize - (allBarSize + allGap);
      groupGap += tmp / 2;
    }

    num offset = vertical ? groupArc.innerRadius : groupArc.startAngle;
    if (vertical) {
      offset += groupGap;
    } else {
      offset += groupGap * dir;
    }

    each(groupNode.nodeList, (colNode, i) {
      if (vertical) {
        num or = offset + sizeList[i];
        colNode.arc = groupArc.copy(innerRadius: offset, outRadius: or);
        offset = or + columnGap;
      } else {
        var diffAngle = sizeList[i] * dir;
        colNode.arc = groupArc.copy(startAngle: offset, sweepAngle: diffAngle);
        offset += diffAngle;
        offset += columnGap * dir;
      }
    });
  }

  @override
  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex, LayoutType type) {
    final bool vertical = series.direction == Direction.vertical;
    final colArc = columnNode.arc;
    var coord = findPolarCoord();
    each(columnNode.nodeList, (node, i) {
      var data = node.data.data;
      if (data == null) {
        node.arc = Arc.zero;
        node.position = Offset.zero;
        return;
      }
      var up = coord.dataToPosition(data.x, node.up);
      var down = coord.dataToPosition(data.x, node.down);
      if (vertical) {
        node.arc = colArc.copy(startAngle: down.angle.first, sweepAngle: up.angle.last - down.angle.first);
      } else {
        node.arc = colArc.copy(innerRadius: down.radius.first, outRadius: up.radius.last);
      }
      node.position = node.arc.centroid();
    });
  }

  @override
  StackAnimationNode onCreateAnimatorNode(SingleNode<T, P> node, DiffType diffType, LayoutType type) {
    if (diffType == DiffType.update) {
      return StackAnimationNode(arc: node.arc, offset: node.arc.centroid());
    }
    Arc arc;
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      arc = node.arc.copy(innerRadius: 0, outRadius: 0);
    } else {
      arc = node.arc.copy(outRadius: node.arc.innerRadius);
    }
    return StackAnimationNode(arc: arc, offset: arc.centroid());
  }

  @override
  void onAnimatorUpdate(SingleNode<T, P> node, double t, var startMap, var endMap) {
    var e = endMap[node]!.arc;
    if (e == null) {
      return;
    }
    if (series.direction == Direction.vertical) {
      ///角度增加
      double sweepAngle = e.sweepAngle * t;
      node.arc = Arc(
        innerRadius: e.innerRadius,
        outRadius: e.outRadius,
        sweepAngle: sweepAngle,
        startAngle: e.startAngle,
        center: e.center,
      );
      return;
    }

    ///半径增加
    double outerRadius = e.innerRadius + (e.outRadius - e.innerRadius) * t;
    node.arc = Arc(
      innerRadius: e.innerRadius,
      outRadius: outerRadius,
      sweepAngle: e.sweepAngle,
      startAngle: e.startAngle,
      center: e.center,
    );
  }

  @override
  SingleNode<T, P>? findNode(Offset offset) {
    for (var ele in nodeMap.values) {
      if (offset.inArc(ele.arc)) {
        return ele;
      }
    }
    return null;
  }

  @override
  Offset getTranslation() {
    return findPolarCoord().translation;
  }

  @override
  Offset getMaxTranslation() {
    return findPolarCoord().getMaxScroll();
  }

  @override
  CoordType get coordSystem => CoordType.polar;
}
