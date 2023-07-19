import 'dart:math';
import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';

class BarLayoutHelper extends BaseGridLayoutHelper<BarItemData, BarGroupData, BarSeries> {
  ///布局StackGroupNode
  @override
  void onLayoutColumnForGrid(
    AxisGroup<BarItemData, BarGroupData> axisGroup,
    GroupNode<BarItemData, BarGroupData> groupNode,
    AxisIndex xIndex,
    DynamicData x,
  ) {
    final int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int colGapCount = groupInnerCount - 1;
    if (colGapCount <= 1) {
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
      canUseSize = groupSize * 0.5;
    }
    double allBarSize = 0;

    ///计算Group占用的大小
    List<double> sizeList = [];
    each(groupNode.nodeList, (node, i) {
      var first = node.nodeList.first.data;
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

    DynamicData tmpData = DynamicData(0);
    each(groupNode.nodeList, (node, i) {
      var parent = node.data.data.first.parent;
      int yIndex = parent.yAxisIndex ?? series.yAxisIndex;
      var coord = context.findGridCoord();
      Rect up, down;
      if (vertical) {
        up = coord.dataToRect(xIndex.axisIndex, x, yIndex, tmpData.change(node.getUp()));
        down = coord.dataToRect(xIndex.axisIndex, x, yIndex, tmpData.change(node.getDown()));
      } else {
        up = coord.dataToRect(xIndex.axisIndex, tmpData.change(node.getUp()), yIndex, x);
        down = coord.dataToRect(xIndex.axisIndex, tmpData.change(node.getDown()), yIndex, x);
      }

      double h = (up.top - down.top).abs();
      double w = (up.left - down.left).abs();
      Rect tmpRect;
      if (vertical) {
        tmpRect = Rect.fromLTWH(offset, groupRect.bottom - h, sizeList[i], h);
        offset += columnGap + sizeList[i];
      } else {
        tmpRect = Rect.fromLTWH(groupRect.left, offset, w, sizeList[i]);
        offset += columnGap + sizeList[i];
      }
      node.rect = tmpRect;
    });
  }

  @override
  void onLayoutColumnForPolar(
    AxisGroup<BarItemData, BarGroupData> axisGroup,
    GroupNode<BarItemData, BarGroupData> groupNode,
    AxisIndex xIndex,
    DynamicData x,
  ) {
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
      var first = node.nodeList.first.data;
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
      var parent = colNode.data.data.first.parent;
      int polarIndex = parent.polarAxisIndex ?? series.polarAxisIndex;
      var coord = context.findPolarCoord(polarIndex);
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
  void onLayoutNodeForPolar(ColumnNode<BarItemData, BarGroupData> columnNode, AxisIndex xIndex) {
    super.onLayoutNodeForPolar(columnNode, xIndex);
    if (series.innerGap.abs() == 0 || columnNode.nodeList.length < 2) {
      return;
    }
    bool vertical = series.direction == Direction.vertical;
    each(columnNode.nodeList, (node, i) {
      var arc = node.arc;
      if (vertical) {
        var dd = 2 * pi * arc.outRadius;
        num per = 360 * series.innerGap / dd;
        if (arc.sweepAngle <= per) {
          per = 0;
        }
        node.arc = arc.copy(sweepAngle: arc.sweepAngle - per, padAngle: per);
      } else {
        node.arc = arc.copy(outRadius: arc.outRadius - series.innerGap);
      }
      node.position = node.arc.centroid();
    });

  }

  @override
  AreaStyle? buildAreaStyle(SingleNode<BarItemData, BarGroupData> node) {
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(node);
    }
    var chartTheme = context.config.theme;
    return AreaStyle(color: chartTheme.getColor(node.data.groupIndex)).convert(node.status);
  }

  @override
  LineStyle? buildLineStyle(SingleNode<BarItemData, BarGroupData> node) {
    if (series.borderStyleFun != null) {
      return series.borderStyleFun?.call(node);
    }
    var theme = context.config.theme.barTheme;
    return theme.getBorderStyle();
  }
}
