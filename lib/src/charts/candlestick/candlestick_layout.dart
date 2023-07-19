import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

import 'candlestick_node.dart';

class CandlestickLayout extends ChartLayout<CandleStickSeries, List<CandleStickGroup>> {
  List<CandlestickGroupNode> nodeList = [];

  @override
  void onLayout(List<CandleStickGroup> data, LayoutAnimatorType type) {
    List<CandlestickGroupNode> list = [];

    each(data, (group, p1) {
      var groupNode = CandlestickGroupNode(group, []);
      each(group.data, (p0, p1) {
        groupNode.nodeList.add(CandlestickNode(group, p0));
      });
    });

    if (list.isEmpty) {
      nodeList = list;
      return;
    }

    GridCoord coord = findGridCoord();

    each(list, (group, p1) {
      if (group.nodeList.isEmpty) {
        return;
      }

      int xIndex = group.data.xAxisIndex;
      int yIndex = group.data.yAxisIndex;
      Rect rect = coord.dataToRect(
        xIndex,
        DynamicData(group.nodeList.first.data.time),
        yIndex,
        DynamicData(group.nodeList.first.data.highest),
      );
      num size = rect.width;
      num boxWidth = 0;
      if (series.boxWidth != null) {
        boxWidth = series.boxWidth!.convert(size);
        if (boxWidth > size) {
          boxWidth = size;
        }
      } else {
        num m1 = series.boxMinWidth.convert(size);
        num m2 = series.boxMaxWidth.convert(size);
        boxWidth = (m1 + m2) / 2;
        if (boxWidth > size) {
          boxWidth = size;
        }
      }

      each(group.nodeList, (p0, p1) {
        _layoutSingleNode(coord, p0, boxWidth, xIndex, yIndex);
      });
    });

    nodeList = list;
  }

  void _layoutSingleNode(GridCoord coord, CandlestickNode node, num boxWidth, int xIndex, int yIndex) {
    var data = node.data;
    double half = boxWidth * 0.5;
    DynamicData dd = DynamicData(data.time);
    Offset minCenter = coord.dataToRect(xIndex, dd, yIndex, DynamicData(data.lowest)).topCenter;

    Offset openCenter = coord.dataToRect(xIndex, dd, yIndex, DynamicData(data.open)).topCenter;
    Offset openLeft = openCenter.translate(-half, 0);
    Offset openRight = openCenter.translate(half, 0);

    Offset closeCenter = coord.dataToRect(xIndex, dd, yIndex, DynamicData(data.close)).topCenter;
    Offset closeLeft = closeCenter.translate(-half, 0);
    Offset closeRight = closeCenter.translate(half, 0);
    Offset maxCenter = coord.dataToRect(xIndex, dd, yIndex, DynamicData(data.highest)).topCenter;

    Path path = Path();
    path.moveTo(minCenter.dx, minCenter.dy);
    if (data.close >= data.open) {
      path.lineTo(openCenter.dx, openCenter.dy);
      path.moveTo(closeCenter.dx, closeCenter.dy);
      path.lineTo(maxCenter.dx, maxCenter.dy);
    } else {
      path.lineTo(closeCenter.dx, closeCenter.dy);
      path.moveTo(openCenter.dx, openCenter.dy);
      path.lineTo(maxCenter.dx, maxCenter.dy);
    }
    node.path = path;
    path = Path();
    path.moveTo(openLeft.dx, openLeft.dy);
    path.lineTo(openRight.dx, openRight.dy);
    path.lineTo(closeRight.dx, closeRight.dy);
    path.lineTo(closeLeft.dx, closeLeft.dy);
    path.close();
    node.areaPath = path;
  }

  CandlestickNode? oldNode;

  CandlestickNode? hoverEnter(Offset offset) {
    CandlestickNode? curNode = findNode(offset);
    if (curNode == oldNode) {
      return null;
    }
    if (oldNode != null) {
      oldNode?.removeStates([ViewState.hover, ViewState.focused]);
    }
    oldNode = curNode;
    curNode?.addStates([ViewState.hover, ViewState.focused]);
    notifyLayoutUpdate();
    return curNode;
  }

  void clearHover() {
    if (oldNode != null) {
      oldNode?.removeStates([ViewState.hover, ViewState.focused]);
      oldNode = null;
      notifyLayoutUpdate();
    }
  }

  CandlestickNode? findNode(Offset offset) {
    var of = context.findGridCoord().getTranslation();
    offset = offset.translate(of.dx, of.dy);
    for (var group in nodeList) {
      for (var node in group.nodeList) {
        if (node.path.contains(offset)) {
          return node;
        }
      }
    }
    return null;
  }
}
