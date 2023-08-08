import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class BoxplotHelper extends StackGridHelper<BoxplotData, BoxplotGroup, BoxplotSeries> {
  BoxplotHelper(super.context, super.series);

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
      if (groupData.boxSize != null) {
        tmpSize = groupData.boxSize!.convert(canUseSize);
      } else {
        tmpSize = canUseSize / groupInnerCount;
        if (groupData.boxMaxSize != null) {
          var s = groupData.boxMaxSize!.convert(canUseSize);
          if (tmpSize > s) {
            tmpSize = s;
          }
        }
        if (groupData.boxMinSize != null) {
          var size = groupData.boxMinSize!.convert(canUseSize);
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

    final DynamicData tmpData = DynamicData(0);
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
  void onLayoutNode(ColumnNode<BoxplotData, BoxplotGroup> columnNode, AxisIndex xIndex) {
    final bool vertical = series.direction == Direction.vertical;
    final Rect rect = columnNode.rect;
    for (var node in columnNode.nodeList) {
      _layoutSingleNode(node, rect, vertical);
    }
  }

  void _layoutSingleNode(SingleNode<BoxplotData, BoxplotGroup> node, Rect colRect, bool vertical) {
    var data = node.data;
    if (data == null) {
      return;
    }
    var group = node.parent;
    Offset minC = computeOffset(colRect, data.min, group.xAxisIndex, vertical);
    Offset downC = computeOffset(colRect, data.downAve4, group.xAxisIndex, vertical);
    Offset middleC = computeOffset(colRect, data.middle, group.xAxisIndex, vertical);
    Offset upC = computeOffset(colRect, data.upAve4, group.xAxisIndex, vertical);
    Offset maxC = computeOffset(colRect, data.max, group.xAxisIndex, vertical);

    double tx = vertical ? colRect.width / 2 : 0;
    double ty = vertical ? 0 : colRect.height / 2;

    Path areaPath = Path();
    Path path = Path();
    if (vertical) {
      areaPath.moveTo2(downC.translate(-tx, 0));
      areaPath.lineTo2(downC.translate(tx, 0));
      areaPath.lineTo2(upC.translate(tx, 0));
      areaPath.lineTo2(upC.translate(-tx, 0));
      areaPath.lineTo2(downC.translate(-tx, 0));
      areaPath.close();
      node.extSet("areaPath", areaPath);

      path.moveTo2(minC.translate(-tx, 0));
      path.lineTo2(minC.translate(tx, 0));
      path.moveTo2(minC);
      path.lineTo2(downC);

      path.addPath(areaPath, Offset.zero);

      path.moveTo2(upC);
      path.lineTo2(maxC);

      path.moveTo2(maxC.translate(-tx, 0));
      path.lineTo2(maxC.translate(tx, 0));
      path.moveTo2(middleC.translate(-tx, 0));
      path.lineTo2(middleC.translate(tx, 0));
      node.extSet("path", path);
    } else {
      areaPath.moveTo2(downC.translate(0, -ty));
      areaPath.lineTo2(downC.translate(0, ty));
      areaPath.lineTo2(upC.translate(0, ty));
      areaPath.lineTo2(upC.translate(0, -ty));
      areaPath.close();
      node.extSet("areaPath", areaPath);
      path.moveTo2(minC.translate(0, -ty));
      path.lineTo2(minC.translate(0, ty));
      path.moveTo2(minC);
      path.lineTo2(downC);
      path.addPath(areaPath, Offset.zero);
      path.moveTo2(upC);
      path.lineTo2(maxC);
      path.moveTo2(maxC.translate(0, -ty));
      path.lineTo2(maxC.translate(0, ty));
      path.moveTo2(middleC.translate(0, -ty));
      path.lineTo2(middleC.translate(0, ty));
      node.extSet("path", path);
    }
  }

  Offset computeOffset(Rect colRect, num data, int axisIndex, bool vertical) {
    var coord = findGridCoord();
    if (vertical) {
      return Offset((colRect.left + colRect.right) / 2, coord.dataToPoint(axisIndex, data.toData(), false).first.dy);
    }
    return Offset(
      coord.dataToPoint(axisIndex, data.toData(), true).first.dx,
      (colRect.top + colRect.bottom) / 2,
    );
  }

  @override
  Map<int, List<SingleNode<BoxplotData, BoxplotGroup>>> splitDataByPage(var list, int start, int end) {
    Map<int, List<SingleNode<BoxplotData, BoxplotGroup>>> resultMap = {};
    double w = width;
    double h = height;
    bool vertical = series.direction == Direction.vertical;
    double size = vertical ? w : h;
    for (int i = start; i < end; i++) {
      var node = list[i];
      Path path = node.extGet("path");
      Rect rect = path.getBounds();
      double s = vertical ? rect.left : rect.top;
      int index = s ~/ size;
      List<SingleNode<BoxplotData, BoxplotGroup>> tmpList = resultMap[index] ?? [];
      resultMap[index] = tmpList;
      tmpList.add(node);
    }
    return resultMap;
  }

  @override
  SeriesType get seriesType => SeriesType.boxplot;

}
