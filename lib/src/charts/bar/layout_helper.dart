import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/model/stack_data.dart';
import 'package:flutter/cupertino.dart';
import 'data_helper.dart';
import 'layout/group_node.dart';
import 'layout/single _node.dart';
import 'layout/column_node.dart';

/// 辅助柱状图、折线图等二维坐标系进行布局
class GridLayoutHelper extends ChartLayout<BarSeries, List<GridGroupData>> {
  List<SingleNode> nodeList = [];
  DataHelper helper = DataHelper();

  ///映射数据到节点
  Map<GridItemData, SingleNode> dataNodeMap = {};

  List<DynamicData> getAxisExtreme(BarSeries series, int axisIndex, bool isXAxis) {
    List<DynamicData> dl = [];
    for (var group in series.data) {
      if (group.data.isEmpty) {
        continue;
      }
      int xIndex = group.xAxisIndex ?? series.xAxisIndex;
      if (xIndex < 0) {
        xIndex = 0;
      }
      int yIndex = group.yAxisIndex ?? series.yAxisIndex;
      if (yIndex < 0) {
        yIndex = 0;
      }
      if (isXAxis && xIndex != axisIndex) {
        continue;
      }
      if (!isXAxis && yIndex != axisIndex) {
        continue;
      }
      num maxValue = group.data.first.up;
      num minValue = group.data.first.down;
      if (maxValue < minValue) {
        num t = minValue;
        minValue = maxValue;
        maxValue = t;
      }
      for (var data in group.data) {
        if (isXAxis) {
          dl.add(data.x);
        } else {
          maxValue = max([maxValue, data.down]);
          maxValue = max([maxValue, data.up]);
          minValue = min([maxValue, data.down]);
          minValue = min([maxValue, data.up]);
        }
      }
      if (!isXAxis) {
        dl.add(DynamicData(minValue));
        dl.add(DynamicData(maxValue));
      }
    }
    return dl;
  }

  DynamicText getAxisMaxText(BarSeries series, int axisIndex, bool isXAxis) {
    List<DynamicData> dl = getAxisExtreme(series, axisIndex, false);
    if (dl.isEmpty) {
      return DynamicText.empty;
    }
    String text = dl.first.getText();
    for (DynamicData data in dl) {
      String str = data.getText();
      if (str.length > text.length) {
        text = str;
      }
    }
    return DynamicText(text);
  }

  @override
  void onLayout(List<GridGroupData> data, LayoutAnimatorType type) {
    AxisGroup axisGroup = helper.parse(series, data);

    List<SingleNode> nodeList = [];

    bool vertical = series.direction == Direction.vertical;
    final DynamicData tmpData = DynamicData(1000000);

    ///开始布局
    var coord = context.findGridCoord();
    axisGroup.groupMap.forEach((key, value) {
      List<StackGroup> groupList = value;
      List<GroupNode> groupNodeList = [];

      ///创建节点
      for (var group in groupList) {
        var groupNode = GroupNode(group);
        groupNodeList.add(groupNode);
        List<ColumnNode> stackNodeList = [];
        for (var stack in group.column) {
          var stackNode = ColumnNode(stack);
          stackNode.nodeList = buildSingleNode(stackNode, stack.data);
          stackNodeList.add(stackNode);
        }
        groupNode.nodeList = stackNodeList;
      }

      ///布局
      for (var groupNode in groupNodeList) {
        var xIndex = key;
        if (groupNode.nodeList.isEmpty) {
          continue;
        }
        var x = groupNode.getX();
        Rect areaRect = coord.dataToPosition(xIndex.index, x, 0, tmpData.change(groupNode.nodeList.first.getUp()));
        if (vertical) {
          groupNode.rect = Rect.fromLTWH(areaRect.left, 0, areaRect.width, height);
        } else {
          groupNode.rect = Rect.fromLTWH(0, areaRect.top, width, areaRect.height);
        }
        onLayoutGroupNode(axisGroup, groupNode, coord, xIndex, x);
      }

      for (var node in groupNodeList) {
        for (var cn in node.nodeList) {
          nodeList.addAll(cn.nodeList);
        }
      }
    });

    this.nodeList = nodeList;
    notifyLayoutEnd();
  }

  List<SingleNode> buildSingleNode(ColumnNode stackNode, List<StackData> dataList) {
    List<SingleNode> nodeList = [];
    each(dataList, (data, i) {
      SingleNode node = SingleNode(data);
      nodeList.add(node);
    });
    return nodeList;
  }

  ///布局StackGroupNode
  void onLayoutGroupNode(AxisGroup axisGroup, GroupNode groupNode, GridCoord coord, AxisIndex xIndex, DynamicData x) {
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
      int yIndex = node.data.data.first.parent.yAxisIndex ?? series.yAxisIndex;
      num up = node.getUp();

      ///确定上界和下界
      Rect r1 = coord.dataToPosition(xIndex.index, x, yIndex, tmpData.change(up));
      Rect r2 = coord.dataToPosition(xIndex.index, x, yIndex, tmpData.change(node.getDown()));

      double h = (r1.top - r2.top).abs();
      double w = (r1.left - r2.left).abs();
      Rect tmpRect;
      if (vertical) {
        tmpRect = Rect.fromLTWH(left, rect.bottom - h, sizeList[i], h);
        left += columnGap + sizeList[i];
      } else {
        tmpRect = Rect.fromLTWH(left, top, w, sizeList[i]);
        top += columnGap + sizeList[i];
      }
      node.rect = tmpRect;
      onLayoutStackNode(node);
    });
  }

  ///布局StackNode
  void onLayoutStackNode(ColumnNode stackNode) {
    final num up = stackNode.nodeList[stackNode.nodeList.length - 1].up;
    final num down = stackNode.nodeList.first.down;
    final Rect rect = stackNode.rect;
    final num diff = up - down;
    final bool vertical = series.direction == Direction.vertical;
    final double size = vertical ? rect.height : rect.width;

    double bottom = rect.bottom;
    double left = rect.left;
    for (var node in stackNode.nodeList) {
      num percent = (node.up - node.down) / diff;
      double length = percent * size;
      if (vertical) {
        bottom = bottom - length;
        node.rect = Rect.fromLTWH(rect.left, bottom, rect.width, length);
      } else {
        node.rect = Rect.fromLTWH(left, rect.top, length, rect.height);
        left += length;
      }
    }
  }
}
