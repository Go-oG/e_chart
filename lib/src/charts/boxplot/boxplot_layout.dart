import 'dart:ui';

import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

import 'boxplot_node.dart';

class BoxplotLayout extends ChartLayout<BoxplotSeries, List<BoxplotData>> {
  List<BoxplotNode> nodeList = [];

  @override
  void onLayout(List<BoxplotData> data, LayoutAnimatorType type) {
    List<BoxplotNode> list = [];
    each(data, (p0, p1) {
      list.add(BoxplotNode(p0));
    });
    GridCoord coord = context.findGridCoord();
    if (list.isEmpty) {
      nodeList = list;
      return;
    }

    Rect rect = coord.dataToPosition(series.xAxisIndex, data.first.x, series.yAxisIndex, data.first.min);
    num size = series.direction == Direction.vertical ? rect.width : rect.height;
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

    each(list, (p0, p1) {
      _layoutSingleNode(coord, p0, boxWidth);
    });
    nodeList = list;
  }

  void _layoutSingleNode(GridCoord coord, BoxplotNode node, num boxWidth) {
    int xIndex = series.xAxisIndex;
    int yIndex = series.yAxisIndex;
    var data = node.data;
    double half = boxWidth * 0.5;

    Offset minCenter = coord.dataToPosition(xIndex, data.x, yIndex, data.min).topCenter;
    Offset minLeft = minCenter.translate(-half, 0);
    Offset minRight = minCenter.translate(half, 0);

    Offset downCenter = coord.dataToPosition(xIndex, data.x, yIndex, data.downAve4).topCenter;
    Offset downLeft = minCenter.translate(-half, 0);
    Offset downRight = minCenter.translate(half, 0);

    Offset middleCenter = coord.dataToPosition(xIndex, data.x, yIndex, data.downAve4).topCenter;
    Offset middleLeft = middleCenter.translate(-half, 0);
    Offset middleRight = middleCenter.translate(half, 0);

    Offset upAveCenter = coord.dataToPosition(xIndex, data.x, yIndex, data.upAve4).topCenter;
    Offset upAveLeft = upAveCenter.translate(-half, 0);
    Offset upAveRight = upAveCenter.translate(half, 0);

    Offset maxCenter = coord.dataToPosition(xIndex, data.x, yIndex, data.max).topCenter;
    Offset maxLeft = maxCenter.translate(-half, 0);
    Offset maxRight = maxCenter.translate(half, 0);

    Path areaPath = Path();

    Path path = Path();

    path.moveTo(minLeft.dx, minLeft.dy);
    path.lineTo(minRight.dx, minRight.dy);

    path.moveTo(minCenter.dx, minCenter.dy);
    path.lineTo(downCenter.dx, downCenter.dy);

    path.moveTo(downLeft.dx, downLeft.dy);
    path.lineTo(downRight.dx, downRight.dy);

    path.lineTo(upAveRight.dx, upAveRight.dy);
    path.lineTo(upAveLeft.dx, upAveLeft.dy);
    path.lineTo(downLeft.dx, downLeft.dy);

    path.moveTo(middleLeft.dx, middleLeft.dy);
    path.lineTo(middleRight.dx, middleRight.dy);

    path.moveTo(upAveCenter.dx, upAveCenter.dy);
    path.lineTo(maxCenter.dx, maxCenter.dy);

    path.moveTo(maxLeft.dx, maxLeft.dy);
    path.lineTo(maxRight.dx, maxRight.dy);

    node.path = path;

    areaPath.moveTo(downLeft.dx, downLeft.dy);
    areaPath.lineTo(downRight.dx, downRight.dy);
    areaPath.lineTo(upAveRight.dx, upAveRight.dy);
    areaPath.lineTo(upAveLeft.dx, upAveLeft.dy);
    areaPath.close();
    node.areaPath = areaPath;
  }

  BoxplotNode? oldNode;

  BoxplotNode? hoverEnter(Offset offset) {
    BoxplotNode? curNode = findNode(offset);
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

  BoxplotNode? findNode(Offset offset) {
    var of = context.findGridCoord().getTranslation(series.xAxisIndex, series.yAxisIndex);
    offset = offset.translate(of.dx, of.dy);
    for (BoxplotNode node in nodeList) {
      if (node.path.contains(offset)) {
        return node;
      }
    }
    return null;
  }
}
