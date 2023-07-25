import 'dart:math';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

import '../../helper/base_polar_layout.dart';
import '../../helper/model/axis_index.dart';

class BarPolarHelper extends BasePolarLayoutHelper<BarItemData, BarGroupData, BarSeries> {
  ///根据给定的页码编号，返回对应的数据
  List<SingleNode<BarItemData, BarGroupData>> getPageData(List<int> pages) {
    return [];
  }

  @override
  void onLayoutColumn(var axisGroup, var groupNode, AxisIndex xIndex, DynamicData x) {
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
      int polarIndex = series.polarIndex;
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
  void onLayoutNode(ColumnNode<BarItemData, BarGroupData> columnNode, AxisIndex xIndex) {
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
  AreaStyle? buildAreaStyle(BarItemData? data, BarGroupData group, int groupIndex, Set<ViewState>? status) {
    if (series.areaStyleFun != null) {
      if (data == null) {
        return null;
      }
      return series.areaStyleFun?.call(data, group);
    }
    var chartTheme = context.config.theme;
    return AreaStyle(color: chartTheme.getColor(groupIndex)).convert(status);
  }

  @override
  LineStyle? buildLineStyle(BarItemData? data, BarGroupData group, int groupIndex, Set<ViewState>? status) {
    if (series.borderStyleFun != null) {
      if (data == null) {
        return null;
      }
      return series.borderStyleFun?.call(data, group);
    }
    var theme = context.config.theme.barTheme;
    return theme.getBorderStyle()?.convert(status);
  }
}
