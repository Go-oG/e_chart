import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/grid/base_data.dart';

import 'base_grid_series.dart';
import 'column_node.dart';
import 'data_helper.dart';
import 'group_node.dart';
import 'single_node.dart';

abstract class BaseGridLayoutHelper<T extends BaseItemData, P extends BaseGroupData<T>, S extends BaseGridSeries<T, P>>
    extends ChartLayout<S, List<P>> {
  List<SingleNode<T, P>> nodeList = [];

  DataHelper<T, P, S> helper = DataHelper();

  ///映射数据到节点
  Map<T, SingleNode<T, P>> dataNodeMap = {};

  List<DynamicData> getAxisExtreme(S series, int axisIndex, bool isXAxis) {
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

  DynamicText getAxisMaxText(S series, int axisIndex, bool isXAxis) {
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
  void onLayout(List<P> data, LayoutAnimatorType type) {
    AxisGroup<T, P> axisGroup = helper.parse(series, data);
    List<SingleNode<T, P>> nodeList = [];
    bool vertical = series.direction == Direction.vertical;
    final DynamicData tmpData = DynamicData(1000000);

    Map<T, SingleNode<T, P>> nodeMap = {};

    ///开始布局
    var coord = context.findGridCoord();
    axisGroup.groupMap.forEach((key, value) {
      List<StackGroup<T, P>> groupList = value;
      List<GroupNode<T, P>> groupNodeList = [];

      ///创建节点
      for (var group in groupList) {
        var groupNode = GroupNode<T, P>(group);
        groupNodeList.add(groupNode);
        List<ColumnNode<T, P>> stackNodeList = [];
        for (var stack in group.column) {
          ColumnNode<T, P> stackNode = ColumnNode(stack);
          stackNode.nodeList = buildSingleNode(stackNode, stack.data);
          for (var ele in stackNode.nodeList) {
            nodeMap[ele.data.data] = ele;
          }

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
        Rect areaRect = coord.dataToRect(xIndex.index, x, 0, tmpData.change(groupNode.nodeList.first.getUp()));
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
    this.dataNodeMap = nodeMap;
  }

  List<SingleNode<T, P>> buildSingleNode(ColumnNode<T, P> stackNode, List<StackData<T, P>> dataList) {
    List<SingleNode<T, P>> nodeList = [];
    each(dataList, (data, i) {
      SingleNode<T, P> node = SingleNode(data);
      nodeList.add(node);
    });
    return nodeList;
  }

  ///布局StackGroupNode
  void onLayoutGroupNode(
    AxisGroup<T, P> axisGroup,
    GroupNode<T, P> groupNode,
    GridCoord coord,
    AxisIndex xIndex,
    DynamicData x,
  );

  ///布局StackNode
  void onLayoutStackNode(ColumnNode<T, P> stackNode) {
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
