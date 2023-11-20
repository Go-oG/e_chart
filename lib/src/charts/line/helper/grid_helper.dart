import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/line/helper/line_helper.dart';

import '../line_node.dart';

class LineGridHelper extends GridHelper<StackItemData, LineGroupData, LineSeries> implements LineHelper {
  List<LineNode> _lineList = [];

  LineGridHelper(super.context, super.view, super.series);

  List<LineNode> get lineList => _lineList;

  double _animatorPercent = 1;

  @override
  List<LineNode> getLineNodeList() {
    return _lineList;
  }

  @override
  void onLayoutNode(var columnNode, LayoutType type) {
    super.onLayoutNode(columnNode, type);
    var xIndex = columnNode.parentNode.getXAxisIndex();
    final bool vertical = series.direction == Direction.vertical;
    GridAxis xAxis = findGridCoord().getAxis(xIndex, true);
    for (var node in columnNode.nodeList) {
      if (node.dataIsNull) {
        continue;
      }
      if (vertical) {
        if (xAxis.isCategoryAxis && !xAxis.categoryCenter) {
          node.position = node.rect.topLeft;
        } else {
          node.position = node.rect.topCenter;
        }
      } else {
        if (xAxis.isCategoryAxis && !xAxis.categoryCenter) {
          node.position = node.rect.topRight;
        } else {
          node.position = node.rect.centerRight;
        }
      }
    }
  }

  @override
  void onLayoutDataEnd(DataHelper<StackItemData, LineGroupData> helper,
      List<StackData<StackItemData, LineGroupData>> dataList, LayoutType type) {
    Map<LineGroupData, List<StackData<StackItemData, LineGroupData>>> dataMap = {};
    each(dataList, (p0, p1) {
      var list = dataMap[p0.parent] ?? [];
      dataMap[p0.parent] = list;
      list.add(p0);
    });
    List<LineGroupData> keyList = List.from(dataMap.keys);
    keyList.sort((a, b) => a.styleIndex.compareTo(b.styleIndex));

    List<LineNode<StackItemData, LineGroupData>> nodeList = [];
    each(keyList, (key, p1) {
      var list = dataMap[key]!;
      nodeList.addAll(convertToNode(list));
    });
    _lineList = nodeList;
    _animatorPercent = 1;
  }

  List<LineNode<StackItemData, LineGroupData>> convertToNode(List<StackData<StackItemData, LineGroupData>> list) {
    List<LineNode<StackItemData, LineGroupData>> nodeList = [];
    each(list, (data, i) {
      int index = data.parentNode.indexOf(data);

      List<Offset> ol = [data.position];
      List<Offset> upList = [Offset(data.position.dx.floorToDouble(), data.position.dy)];
      List<Offset> downList = [
        Offset(data.position.dx.floorToDouble(), index <= 0 ? height : data.parentNode.getAt(index - 1).position.dy)
      ];

      StackData<StackItemData, LineGroupData>? nextData;
      if (data.dataIndex < data.parent.data.length - 1) {
        nextData = data.parent.data[data.dataIndex + 1];
      }
      if (nextData != null && !nextData.attr.hasLayout()) {
        nextData = null;
      }

      num ds = 0;
      if (nextData != null) {
        ds = nextData.borderStyle.smooth;
        ol.add(nextData.position);
        upList.add(nextData.position);
        index = nextData.parentNode.indexOf(nextData);

        if (index <= 0) {
          downList.add(Offset(nextData.position.dx.roundToDouble(), height));
        } else {
          downList.add(Offset(nextData.position.dx.roundToDouble(), nextData.parentNode.getAt(index - 1).position.dy));
        }
      }

      Path? path;
      Path? areaPath;
      if (upList.length >= 2) {
        var step=series.getLineType(context, data.parent);
        path = data.borderStyle.buildPath(upList,lineType: step);
      }

      if (downList.length >= 2 && upList.length >= 2) {
        areaPath = Area(upList, downList, upSmooth: data.borderStyle.smooth, downSmooth: ds).toPath();
      }

      nodeList.add(LineNode(data, path, areaPath, series.getSymbol(context, data)));
    });
    return nodeList;
  }

  @override
  StackAnimatorNode onCreateAnimatorNode(var node, DiffType diffType, bool isStart) {
    if (diffType == DiffType.update ||
        (isStart && diffType == DiffType.remove) ||
        (!isStart && diffType == DiffType.add)) {
      return StackAnimatorNode(offset: node.position);
    }
    return StackAnimatorNode(offset: Offset(node.position.dx, height));
  }

  @override
  void onAnimatorStart(var nodeList) {
    _animatorPercent = 0;
  }

  @override
  void onAnimatorUpdate(var node, double t, var startStatus, var endStatus) {
    _animatorPercent = t;
  }

  @override
  void onAnimatorUpdateEnd(var nodeList, double t) {
    _animatorPercent = t;
  }

  @override
  void onAnimatorEnd(var nodeList) {
    _animatorPercent = 1;
  }

  ///布局直线使用的数据

  @override
  double getAnimatorPercent() {
    return _animatorPercent;
  }
}
