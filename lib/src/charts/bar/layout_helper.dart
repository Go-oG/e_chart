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
    int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int columnCount = groupInnerCount;
    if (columnCount <= 1) {
      columnCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;
    final Rect rect = groupNode.rect;
    final num groupSize = vertical ? rect.width : rect.height;

    double groupGap = series.groupGap.convert(groupSize) * 2;
    double columnGap = series.columnGap.convert(groupSize);
    double allGap = groupGap + columnCount * columnGap;

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

    double left = rect.left + groupGap * 0.5;
    double top = rect.top + groupGap * 0.5;

    DynamicData tmpData = DynamicData(0);
    each(groupNode.nodeList, (node, i) {
      var parent = node.data.data.first.parent;
      int yIndex = parent.yAxisIndex ?? series.yAxisIndex;
      var coord = context.findGridCoord();

      ///上界和下界
      Rect up = coord.dataToRect(xIndex.xIndex, x, yIndex, tmpData.change(node.getUp()));
      Rect down = coord.dataToRect(xIndex.xIndex, x, yIndex, tmpData.change(node.getDown()));
      double h = (up.top - down.top).abs();
      double w = (up.left - down.left).abs();
      Rect tmpRect;
      if (vertical) {
        tmpRect = Rect.fromLTWH(left, rect.bottom - h, sizeList[i], h);
        left += columnGap + sizeList[i];
      } else {
        tmpRect = Rect.fromLTWH(left, top, w, sizeList[i]);
        top += columnGap + sizeList[i];
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
    int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int columnCount = groupInnerCount;
    if (columnCount <= 1) {
      columnCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;

    num angle = groupNode.arc.startAngle;
    num radius = groupNode.arc.innerRadius;

    final DynamicData tmpData = DynamicData(0);

    each(groupNode.nodeList, (node, i) {
      var parent = node.data.data.first.parent;
      int polarIndex = parent.polarAxisIndex ?? series.polarAxisIndex;
      var coord = context.findPolarCoord(polarIndex);

      ///确定上界和下界
      var up = coord.dataToPosition(x, tmpData.change(node.getUp()));
      var down = coord.dataToPosition(x, tmpData.change(node.getDown()));

      Arc arc;
      if (vertical) {
        var tmpAngle = (up.angle[0] - down.angle[0]);
        arc = groupNode.arc.copy(startAngle: angle, sweepAngle: tmpAngle);
        angle += tmpAngle;
      } else {
        var rr = (up.radius[0] - down.radius[0]).abs();
        arc = groupNode.arc.copy(innerRadius: radius, outRadius: radius + rr);
        radius += rr;
      }
      node.arc = arc;
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
