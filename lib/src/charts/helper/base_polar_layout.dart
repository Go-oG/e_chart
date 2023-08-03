import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

///适用于极坐标系的布局帮助者
abstract class BasePolarLayoutHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends BaseGridSeries<T, P>>
    extends BaseStackLayoutHelper<T, P, S> {
  @override
  void onLayoutGroup(GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x) {
    bool vertical = series.direction == Direction.vertical;
    final DynamicData tmpData = DynamicData(1000000);
    var coord = findPolarCoord();
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
  }

  @override
  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex) {
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
  SingleNode<T, P> onCreateAnimatorObj(SingleNode<T, P> data, SingleNode<T, P> node, bool newData, LayoutType type) {
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

  @override
  void onAnimatorStart(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type) {
    Map<T, SingleNode<T, P>> map = {};
    for (var ele in result.startList) {
      if (ele.data != null) {
        map[ele.data!] = ele;
      }
    }
    showNodeMap = map;
  }

  @override
  void onAnimatorUpdate(SingleNode<T, P> node, double t, var startMap, var endMap, LayoutType type) {
    var e = endMap[node]!.arc;
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
    } else {
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
  }

  @override
  void onAnimatorUpdateEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, double t, LayoutType type) {}

  @override
  void onAnimatorEnd(DiffResult<SingleNode<T, P>, SingleNode<T, P>> result, LayoutType type) {
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
  CoordSystem get coordSystem=>CoordSystem.polar;

}
