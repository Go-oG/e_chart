import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/line/helper/line_helper.dart';
import 'package:e_chart/src/charts/line/line_node.dart';

class LinePolarHelper extends PolarHelper<StackItemData, LineGroupData, LineSeries> implements LineHelper {
  List<LineNode> _lineList = [];

  LinePolarHelper(super.context, super.view, super.series);

  List<LineNode> get lineList => _lineList;

  double _animatorPercent = 1;

  @override
  List<LineNode> getLineNodeList() {
    return _lineList;
  }

  @override
  void onLayoutColumn(var axisGroup, var groupNode, LayoutType type) {
    var xIndex = AxisIndex(CoordType.polar, groupNode.getXAxisIndex());
    var xData = groupNode.getXData();
    int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int columnCount = groupInnerCount;
    if (columnCount <= 1) {
      columnCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;
    final Arc arc = groupNode.arc;

    each(groupNode.nodeList, (colNode, i) {
      var coord = findPolarCoord();

      PolarPosition up, down;
      if (vertical) {
        up = coord.dataToPosition(xData, colNode.getUp());
        down = coord.dataToPosition(xData, colNode.getDown());
      } else {
        up = coord.dataToPosition(colNode.getUp(), xData);
        down = coord.dataToPosition(colNode.getDown(), xData);
      }

      num dx = (up.radius[0] - down.radius[0]).abs();
      num dy = (up.angle[0] - down.angle[0]);

      Arc tmpArc;
      if (vertical) {
        tmpArc = arc.copy(sweepAngle: dy);
      } else {
        tmpArc = arc.copy(outRadius: dx);
      }
      colNode.arc = tmpArc;
    });
  }

  @override
  void onLayoutNode(var columnNode, LayoutType type) {
    final bool vertical = series.direction == Direction.vertical;
    var coord = findPolarCoord();
    each(columnNode.nodeList, (node, i) {
      var data = node.dataNull;
      if (data == null) {
        return;
      }
      PolarPosition p;
      if (vertical) {
        p = coord.dataToPosition(data.x, node.up);
      } else {
        p = coord.dataToPosition(node.up, data.x);
      }
      if (vertical) {
        num r = (p.radius.first + p.radius.last) / 2;
        node.position = circlePoint(r, p.angle.last, p.center);
      } else {
        num a = (p.angle.first + p.angle.last) / 2;
        node.position = circlePoint(p.radius.last, a, p.center);
      }
    });
  }


  // void onLayoutEnd(var oldNodeList, var newNodeList, var startMap, var endMap, LayoutType type) {
  //   _animatorPercent = 0;
  //   _updateLine(newNodeList);
  // }

  @override
  void onAnimatorStart(var nodeList) {
    super.onAnimatorStart(nodeList);
    _animatorPercent = 0;
  }

  @override
  void onAnimatorUpdateEnd(var nodeList, double t) {
    _animatorPercent = t;
  }

  @override
  void onAnimatorEnd(var nodeList) {
    super.onAnimatorEnd(nodeList);
    _animatorPercent = 1;
  }

  void _updateLine(List<StackData<StackItemData, LineGroupData>> list) {
    Map<LineGroupData, List<StackData<StackItemData, LineGroupData>>> tmpNodeMap = {};
    for (var node in list) {
      List<StackData<StackItemData, LineGroupData>> tmpList = tmpNodeMap[node.parent] ?? [];
      tmpNodeMap[node.parent] = tmpList;
      tmpList.add(node);
    }
    tmpNodeMap.removeWhere((key, value) => value.isEmpty);

    List<LineNode> resultList = [];
    Map<LineGroupData, List<StackData<StackItemData, LineGroupData>>> stackMap = {};

    tmpNodeMap.forEach((key, value) {
      if (key.isNotStack) {
        var index = value.first.groupIndex;
        resultList.add(buildNormalResult(index, key, value));
      } else {
        stackMap[key] = value;
      }
    });

    ///处理堆叠数据
    List<LineGroupData> keyList = List.from(stackMap.keys);
    keyList.sort((a, b) {
      var ai = stackMap[a]!.first.groupIndex;
      var bi = stackMap[b]!.first.groupIndex;
      return ai.compareTo(bi);
    });
    each(keyList, (key, list) {
      var nl = stackMap[key]!;
      var first = nl.first;
      resultList.add(buildStackResult(first.groupIndex, key, nl, resultList, list));
    });
    _lineList = resultList;
  }

  LineNode buildNormalResult(int groupIndex, LineGroupData group, List<StackData<StackItemData, LineGroupData>> list) {
    List<OptLinePath> borderList = _buildBorderPath(list);
    List<Offset?> ol = _collectOffset(list);
    Map<StackData, LineSymbolNode> nodeMap = {};
    each(ol, (off, i) {
      if (off == null) {
        return;
      }
      if (i >= group.data.length) {
        return;
      }
      var data = group.data[i];
      var symbol = getSymbol(data, group);
      if (symbol != null) {
        nodeMap[data] = LineSymbolNode(group, data, symbol, i, groupIndex)..center = off;
      }
    });
    var itemStyle = series.getAreaStyle(context, list.first, list.first.parent);
    var border = series.getLineStyle(context, list.first, list.first.parent);
    return LineNode(groupIndex, group, ol, borderList, [], nodeMap, itemStyle, border);
  }

  LineNode buildStackResult(
    int groupIndex,
    LineGroupData group,
    List<StackData<StackItemData, LineGroupData>> nodeList,
    List<LineNode> resultList,
    int curIndex,
  ) {
    if (nodeList.isEmpty) {
      return LineNode(groupIndex, group, [], [], [], {}, AreaStyle.empty, LineStyle.empty);
    }
    List<OptLinePath> borderList = _buildBorderPath(nodeList);

    List<Offset?> ol = _collectOffset(nodeList);
    Map<StackData, LineSymbolNode> nodeMap = {};
    each(ol, (off, i) {
      if (off == null) {
        return;
      }
      var data = group.data[i];
      var symbol = getSymbol(data, group);
      if (symbol != null) {
        nodeMap[data] = LineSymbolNode(group, data, symbol, i, groupIndex)..center = off;
      }
    });
    var itemStyle = series.getAreaStyle(context, nodeList.first, nodeList.first.parent);
    var border = series.getLineStyle(context, nodeList.first, nodeList.first.parent);
    return LineNode(groupIndex, group, _collectOffset(nodeList), borderList, [], nodeMap, itemStyle, border);
  }

  ///公用部分
  List<OptLinePath> _buildBorderPath(List<StackData<StackItemData, LineGroupData>> nodeList) {
    if (nodeList.length < 2) {
      return [];
    }
    var group = nodeList.first.parent;
    var olList = _splitList(nodeList);
    olList.removeWhere((element) => element.length < 2);
    List<OptLinePath> borderList = [];
    LineType? stepType = series.stepLineFun?.call(group);

    each(olList, (list, p1) {
      var style = list.first.borderStyle;
      num smooth = stepType != null ? 0 : style.smooth;
      List<Offset> ol = List.from(list.map((e) => e.position));
      if (stepType == null) {
        borderList.add(OptLinePath.build(ol, smooth, style.dash));
      } else {
        Line line = _buildLine(ol, stepType, 0, []);
        borderList.add(OptLinePath.build(line.pointList, smooth, style.dash));
      }
    });
    return borderList;
  }

  Line _buildLine(List<Offset> offsetList, LineType? type, num smooth, List<num> dash) {
    Line line = Line(offsetList, smooth: smooth, dashList: dash);
    if (type != null) {
      if (type == LineType.step) {
        line = Line(line.step(), dashList: dash);
      } else if (type == LineType.after) {
        line = Line(line.stepAfter(), dashList: dash);
      } else {
        line = Line(line.stepBefore(), dashList: dash);
      }
    }
    return line;
  }

  List<List<StackData<StackItemData, LineGroupData>>> _splitList(
      Iterable<StackData<StackItemData, LineGroupData>> nodeList) {
    List<List<StackData<StackItemData, LineGroupData>>> olList = [];
    List<StackData<StackItemData, LineGroupData>> tmpList = [];
    for (var node in nodeList) {
      if (node.dataIsNotNull) {
        tmpList.add(node);
      } else {
        if (tmpList.isNotEmpty) {
          olList.add(tmpList);
          tmpList = [];
        }
      }
    }
    if (tmpList.isNotEmpty) {
      olList.add(tmpList);
      tmpList = [];
    }
    return olList;
  }

  List<Offset?> _collectOffset(List<StackData<StackItemData, LineGroupData>> nodeList) {
    List<Offset?> tmpList = [];
    for (var node in nodeList) {
      if (node.dataIsNotNull) {
        tmpList.add(node.position);
      } else {
        tmpList.add(null);
      }
    }
    return tmpList;
  }

  @override
  double getAnimatorPercent() {
    return _animatorPercent;
  }

  ChartSymbol? getSymbol(StackData data, LineGroupData group) {
    if (series.symbolFun != null) {
      return series.symbolFun?.call(data as StackData<StackItemData, LineGroupData>, group);
    }
    if (context.option.theme.lineTheme.showSymbol) {
      return context.option.theme.lineTheme.symbol;
    }
    return null;
  }
}
