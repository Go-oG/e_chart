import 'dart:ui';
import 'package:e_chart/e_chart.dart';

class BarGridHelper extends BaseGridLayoutHelper<BarItemData, BarGroupData, BarSeries> {
  BarGridHelper(super.context, super.series);

  @override
  void onLayoutColumn(var axisGroup, var groupNode, AxisIndex xIndex, DynamicData x) {
    final int groupInnerCount = axisGroup.getColumnCount(xIndex);
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
      } else {
        tmpRect = Rect.fromLTWH(groupRect.left, offset, w, sizeList[i]);
      }
      offset += columnGap + sizeList[i];
      node.rect = tmpRect;
    });
  }

  @override
  AreaStyle? buildAreaStyle(BarItemData? data, BarGroupData group, int groupIndex, Set<ViewState>? status) {
    if (data == null) {
      return null;
    }
    return series.getAreaStyle(context, data, group, groupIndex, status);
  }

  @override
  LineStyle? buildLineStyle(BarItemData? data, BarGroupData group, int groupIndex, Set<ViewState>? status) {
    if (data == null) {
      return null;
    }
    return series.getBorderStyle(context, data, group, groupIndex, status);
  }

  @override
  void onGridScrollChange(Offset offset) {
    super.onGridScrollChange(offset);
    var list = getNeedShowData();

    Map<BarItemData, SingleNode<BarItemData, BarGroupData>> map = {};
    for (var node in list) {
      if (node.data != null) {
        map[node.data!] = node;
      }
    }
    showNodeMap = map;
  }

  @override
  SeriesType get seriesType => SeriesType.bar;

}
