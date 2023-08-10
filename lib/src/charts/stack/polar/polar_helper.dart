import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

///帮助在极坐标系中进行布局
abstract class PolarHelper<T extends StackItemData, P extends StackGroupData<T>, S extends StackSeries<T, P>> extends StackHelper<T, P, S> {
  PolarHelper(super.context, super.series);

  @override
  void onLayoutGroup(GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x, LayoutType type) {
    bool vertical = series.direction == Direction.vertical;
    var coord = findPolarCoord();
    PolarPosition position;
    if (vertical) {
      position = coord.dataToPosition(x, groupNode.nodeList.first.getUp().toData());
    } else {
      position = coord.dataToPosition(groupNode.nodeList.first.getUp().toData(), x);
    }
    num ir = position.radius.length == 1 ? 0 : position.radius[0];
    num or = position.radius.length == 1 ? position.radius[0] : position.radius[1];
    num sa = position.angle.length < 2 ? coord.getStartAngle() : position.angle[0];
    num ea = position.angle.length >= 2 ? position.angle[1] : position.angle[0];
    groupNode.arc = Arc(center: position.center, innerRadius: ir, outRadius: or, startAngle: sa, sweepAngle: ea - sa);
  }

  @override
  void onLayoutColumn(var axisGroup, var groupNode, AxisIndex xIndex, DynamicData x, LayoutType type) {
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

    DynamicData tmpData = DynamicData(0);

    each(groupNode.nodeList, (colNode, i) {
      var coord = findPolarCoord();
      Arc arc;
      if (vertical) {
        var up = coord.dataToPosition(x, tmpData.change(colNode.getUp()));
        var down = coord.dataToPosition(x, tmpData.change(colNode.getDown()));
        num or = offset + sizeList[i];
        var sa = down.angle[0];
        var tmpAngle = (up.angle[0] - down.angle[0]);
        arc = groupArc.copy(startAngle: sa, sweepAngle: tmpAngle, innerRadius: offset, outRadius: or);
        offset = or + columnGap;
      } else {
        var up = coord.dataToPosition(tmpData.change(colNode.getUp()), x);
        var down = coord.dataToPosition(tmpData.change(colNode.getDown()), x);
        var diffAngle = sizeList[i] * dir;
        arc = groupArc.copy(innerRadius: down.radius[0], outRadius: up.radius[0], startAngle: offset, sweepAngle: diffAngle);
        offset += diffAngle;
        offset += columnGap * dir;
      }
      colNode.arc = arc;
    });
  }

  @override
  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex, LayoutType type) {
    final num up = columnNode.nodeList[columnNode.nodeList.length - 1].up;
    final num down = columnNode.nodeList.first.down;
    final num diff = up - down;
    final bool vertical = series.direction == Direction.vertical;
    final colArc = columnNode.arc;
    final num arcSize = vertical ? colArc.sweepAngle : (colArc.outRadius - colArc.innerRadius).abs();
    num offset = vertical ? colArc.startAngle : colArc.innerRadius;
    each(columnNode.nodeList, (node, i) {
      num percent = (node.up - node.down) / diff;
      num length = percent * arcSize;
      if (vertical) {
        node.arc = colArc.copy(startAngle: offset, sweepAngle: length);
      } else {
        node.arc = colArc.copy(innerRadius: offset, outRadius: offset + length);
      }
      offset += length;
      node.position = node.arc.centroid();
    });
  }

  @override
  AnimatorNode onCreateAnimatorNode(SingleNode<T, P> node, DiffType type) {
    if (type == DiffType.accessor) {
      return AnimatorNode(arc: node.arc, offset: node.arc.centroid());
    }
    Arc arc;
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      arc = node.arc.copy(innerRadius: 0, outRadius: 0);
    } else {
      arc = node.arc.copy(outRadius: node.arc.innerRadius);
    }
    return AnimatorNode(arc: arc, offset: arc.centroid());
  }

  @override
  void onAnimatorStart(var result) {
    Map<T, SingleNode<T, P>> map = {};
    for (var ele in result.startList) {
      if (ele.data != null) {
        map[ele.data!] = ele;
      }
    }
    showNodeMap = map;
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
  void onAnimatorEnd(DiffResult2<SingleNode<T, P>, AnimatorNode, T> result) {
    Map<T, SingleNode<T, P>> map = {};
    for (var ele in result.endList) {
      if (ele.data != null) {
        map[ele.data!] = ele;
      }
    }
    showNodeMap = map;
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
    return findPolarCoord().getTranslation();
  }

  @override
  CoordSystem get coordSystem => CoordSystem.polar;
}
