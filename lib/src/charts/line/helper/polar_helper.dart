import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/line/helper/line_helper.dart';
import 'package:e_chart/src/charts/line/line_node.dart';

class LinePolarHelper extends BasePolarLayoutHelper<LineItemData, LineGroupData, LineSeries> implements LineHelper {
  List<LineNode> _lineList = [];

  LinePolarHelper(super.context, super.series);

  List<LineNode> get lineList => _lineList;

  double _animatorPercent = 1;

  @override
  List<LineNode> getLineNodeList() {
    return _lineList;
  }

  @override
  void onLayoutColumn(var axisGroup, var groupNode, AxisIndex xIndex, DynamicData x) {
    int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int columnCount = groupInnerCount;
    if (columnCount <= 1) {
      columnCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;
    final Arc arc = groupNode.arc;

    DynamicData tmpData = DynamicData(0);
    each(groupNode.nodeList, (colNode, i) {
      var coord = findPolarCoord();

      PolarPosition up, down;
      if (vertical) {
        up = coord.dataToPosition(x, tmpData.change(colNode.getUp()));
        down = coord.dataToPosition(x, tmpData.change(colNode.getDown()));
      } else {
        up = coord.dataToPosition(tmpData.change(colNode.getUp()), x);
        down = coord.dataToPosition(tmpData.change(colNode.getDown()), x);
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
  void onLayoutNode(ColumnNode<LineItemData, LineGroupData> columnNode, AxisIndex xIndex) {
    final bool vertical = series.direction == Direction.vertical;
    var coord = findPolarCoord();
    each(columnNode.nodeList, (node, i) {
      var data = node.data;
      if (data == null) {
        return;
      }
      PolarPosition p;
      if (vertical) {
        p = coord.dataToPosition(data.x, DynamicData(node.up));
      } else {
        p = coord.dataToPosition(DynamicData(node.up), data.x);
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

  @override
  Future<void> onLayoutEnd(var oldNodeList, var oldNodeMap, var newNodeList, var newNodeMap, LayoutType type) async {
    _animatorPercent = 0;
    await super.onLayoutEnd(oldNodeList, oldNodeMap, newNodeList, newNodeMap, type);
    await _updateLine(newNodeList);
  }

  @override
  void onAnimatorStart(var result, LayoutType type) {
    super.onAnimatorStart(result, type);
    _animatorPercent = 0;
  }

  @override
  void onAnimatorUpdateEnd(var result, double t, LayoutType type) {
    super.onAnimatorUpdateEnd(result, t, type);
    _animatorPercent = t;
  }

  @override
  void onAnimatorEnd(var result, LayoutType type) {
    super.onAnimatorEnd(result, type);
    _animatorPercent = 1;
  }

  Future<void> _updateLine(List<SingleNode<LineItemData, LineGroupData>> list) async {
    Map<LineGroupData, List<SingleNode<LineItemData, LineGroupData>>> tmpNodeMap = {};
    for (var node in list) {
      List<SingleNode<LineItemData, LineGroupData>> tmpList = tmpNodeMap[node.parent] ?? [];
      tmpNodeMap[node.parent] = tmpList;
      tmpList.add(node);
    }
    tmpNodeMap.removeWhere((key, value) => value.isEmpty);

    List<LineNode> resultList = [];
    Map<LineGroupData, List<SingleNode<LineItemData, LineGroupData>>> stackMap = {};

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
      resultList.add(buildStackResult(nl.first.groupIndex, key, nl, resultList, list));
    });
    _lineList = resultList;
  }

  LineNode buildNormalResult(int groupIndex, LineGroupData group, List<SingleNode<LineItemData, LineGroupData>> list) {
    List<PathNode> borderList = _buildBorderPath(list);
    List<Offset?> ol = _collectOffset(list);
    Map<LineItemData, SymbolNode> nodeMap = {};
    each(ol, (off, i) {
      if (i >= group.data.length) {
        return;
      }
      var data = group.data[i];
      if (data == null || off == null) {
        return;
      }
      nodeMap[data] = SymbolNode(data, i, groupIndex, off, group);
    });
    return LineNode(groupIndex, group, ol, borderList, [], nodeMap);
  }

  LineNode buildStackResult(
    int groupIndex,
    LineGroupData group,
    List<SingleNode<LineItemData, LineGroupData>> nodeList,
    List<LineNode> resultList,
    int curIndex,
  ) {
    if (nodeList.isEmpty) {
      return LineNode(groupIndex, group, [], [], [], {});
    }
    List<PathNode> borderList = _buildBorderPath(nodeList);

    List<Offset?> ol = _collectOffset(nodeList);
    Map<LineItemData, SymbolNode> nodeMap = {};
    each(ol, (off, i) {
      var data = group.data[i];
      if (data == null || off == null) {
        return;
      }
      nodeMap[data] = SymbolNode(data, i, groupIndex, off, group);
    });

    return LineNode(groupIndex, group, _collectOffset(nodeList), borderList, [], nodeMap);
  }

  ///公用部分
  List<PathNode> _buildBorderPath(List<SingleNode<LineItemData, LineGroupData>> nodeList) {
    if (nodeList.length < 2) {
      return [];
    }
    var group = nodeList.first.parent;
    List<List<Offset>> olList = _splitList(nodeList);
    olList.removeWhere((element) => element.length < 2);
    List<PathNode> borderList = [];
    StepType? stepType = series.stepLineFun?.call(group);

    each(olList, (list, p1) {
      LineStyle? style = buildLineStyle(null, group, p1, null);
      bool smooth = stepType != null ? false : (style == null ? false : style.smooth);
      if (stepType == null) {
        borderList.add(PathNode(list, smooth, style?.dash ?? []));
      } else {
        Line line = _buildLine(list, stepType, false, []);
        borderList.add(PathNode(line.pointList, smooth, style?.dash ?? []));
      }
    });
    return borderList;
  }

  Line _buildLine(List<Offset> offsetList, StepType? type, bool smooth, List<num> dash) {
    Line line = Line(offsetList, smooth: smooth, dashList: dash);
    if (type != null) {
      if (type == StepType.step) {
        line = Line(line.step(), dashList: dash);
      } else if (type == StepType.after) {
        line = Line(line.stepAfter(), dashList: dash);
      } else {
        line = Line(line.stepBefore(), dashList: dash);
      }
    }
    return line;
  }

  List<List<Offset>> _splitList(Iterable<SingleNode<LineItemData, LineGroupData>> nodeList) {
    List<List<Offset>> olList = [];
    List<Offset> tmpList = [];
    for (var node in nodeList) {
      if (node.data != null) {
        tmpList.add(node.position);
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

  List<Offset?> _collectOffset(List<SingleNode<LineItemData, LineGroupData>> nodeList) {
    List<Offset?> tmpList = [];
    for (var node in nodeList) {
      if (node.data != null) {
        tmpList.add(node.position);
      } else {
        tmpList.add(null);
      }
    }
    return tmpList;
  }

  @override
  AreaStyle? buildAreaStyle(LineItemData? data, LineGroupData group, int groupIndex, Set<ViewState>? status) {
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(group, groupIndex,status??{});
    }
    var chartTheme = context.option.theme;
    var theme = chartTheme.lineTheme;
    if (theme.fill) {
      Color fillColor = chartTheme.getColor(groupIndex).withOpacity(theme.opacity);
      return AreaStyle(color: fillColor);
    }
    return null;
  }

  @override
  LineStyle? buildLineStyle(LineItemData? data, LineGroupData group, int groupIndex, Set<ViewState>? status) {
    if (series.lineStyleFun != null) {
      return series.lineStyleFun?.call(group, groupIndex,status??{});
    }
    var chartTheme = context.option.theme;
    var theme = chartTheme.lineTheme;
    return theme.getLineStyle(chartTheme, groupIndex).convert(status);
  }

  @override
  double getAnimatorPercent() {
    return _animatorPercent;
  }

  @override
  SeriesType get seriesType => SeriesType.line;
}
