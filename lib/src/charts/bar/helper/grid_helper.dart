import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/cupertino.dart';
import '../../helper/model/axis_index.dart';

class BarGridHelper extends BaseGridLayoutHelper<BarItemData, BarGroupData, BarSeries> {
  ///根据给定的页码编号，返回对应的数据
  Map<int, List<SingleNode<BarItemData, BarGroupData>>> _pageMap = {};

  List<SingleNode<BarItemData, BarGroupData>> getPageData(List<int> pages) {
    List<SingleNode<BarItemData, BarGroupData>> list = [];
    final map = _pageMap;
    for (int page in pages) {
      var tmp = map[page];
      if (tmp == null || tmp.isEmpty) {
        continue;
      }
      list.addAll(tmp);
    }
    return list;
  }

  @override
  void onLayoutColumn(var axisGroup, var groupNode, AxisIndex xIndex, DynamicData x) {
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

    DynamicData tmpData = DynamicData(0);
    each(groupNode.nodeList, (node, i) {
      var parent = node.nodeList.first.parent;
      int yIndex = parent.yAxisIndex;
      var coord = findGridCoord();
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
  void onLayoutEnd(var oldNodeList, var oldNodeMap, var newNodeList, var newNodeMap, LayoutType type) {
    if (newNodeList.length <= thresholdSize) {
      _pageMap = splitDataByPage(newNodeList, 0, newNodeList.length);
    } else {
      _splitData(newNodeList);
    }
    super.onLayoutEnd(oldNodeList, oldNodeMap, newNodeList, newNodeMap, type);
  }

  final int thresholdSize = 2000;

  void _splitData(List<SingleNode<BarItemData, BarGroupData>> list) async {
    Map<int, List<SingleNode<BarItemData, BarGroupData>>> pageMap = {};
    int l = list.length;
    int c = l ~/ thresholdSize;
    if (c % thresholdSize != 0) {
      c++;
    }
    List<Future<Map<int, List<SingleNode<BarItemData, BarGroupData>>>>> futureList = [];
    for (int i = 0; i < c; i++) {
      int s = i * thresholdSize;
      int e = (i + 1) * thresholdSize;
      if (e > l) {
        e = l;
      }
      futureList.add(Future(() {
        return splitDataByPage(list, s, e);
      }));
    }
    for (var fu in futureList) {
      var map = await fu;
      map.forEach((key, value) {
        if (!pageMap.containsKey(key)) {
          pageMap[key] = value;
        } else {
          List<SingleNode<BarItemData, BarGroupData>> tmpList = pageMap[key]!;
          tmpList.addAll(value);
        }
      });
    }
    _pageMap = pageMap;
    notifyLayoutUpdate();
  }

  Map<int, List<SingleNode<BarItemData, BarGroupData>>> splitDataByPage(
    List<SingleNode<BarItemData, BarGroupData>> list,
    int start,
    int end,
  ) {
    Map<int, List<SingleNode<BarItemData, BarGroupData>>> resultMap = {};
    double w = width;
    double h = height;
    bool vertical = series.direction == Direction.vertical;
    double size = vertical ? w : h;
    for (int i = start; i < end; i++) {
      var node = list[i];
      Rect rect = node.rect;
      double s = vertical ? rect.left : rect.top;
      int index = s ~/ size;
      List<SingleNode<BarItemData, BarGroupData>> tmpList = resultMap[index] ?? [];
      resultMap[index] = tmpList;
      tmpList.add(node);
    }
    return resultMap;
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
