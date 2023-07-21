import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

import '../grid/model/axis_index.dart';
import 'line_node.dart';

class LineLayoutHelper extends BaseGridLayoutHelper<LineItemData, LineGroupData, LineSeries> {
  List<LineNode> _lineList = [];

  List<LineNode> get lineList => _lineList;

  @override
  void onLayoutColumnForGrid(var axisGroup, var groupNode, AxisIndex xIndex, DynamicData x) {
    int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int columnCount = groupInnerCount;
    if (columnCount <= 1) {
      columnCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;
    final Rect groupRect = groupNode.rect;
    DynamicData tmpData = DynamicData(0);
    var coord = context.findGridCoord();
    each(groupNode.nodeList, (node, i) {
      int yIndex = groupNode.getYAxisIndex();
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
        tmpRect = Rect.fromLTWH(groupRect.left, groupRect.bottom - h, groupRect.width, h);
      } else {
        tmpRect = Rect.fromLTWH(groupRect.left, groupRect.top, w, groupRect.height);
      }
      node.rect = tmpRect;
    });
  }

  @override
  void onLayoutColumnForPolar(var axisGroup, var groupNode, AxisIndex xIndex, DynamicData x) {
    int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int columnCount = groupInnerCount;
    if (columnCount <= 1) {
      columnCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;
    final Arc arc = groupNode.arc;

    DynamicData tmpData = DynamicData(0);
    each(groupNode.nodeList, (node, i) {
      int polarIndex = series.polarIndex;
      var coord = context.findPolarCoord(polarIndex);

      PolarPosition up, down;
      if (vertical) {
        up = coord.dataToPosition(x, tmpData.change(node.getUp()));
        down = coord.dataToPosition(x, tmpData.change(node.getDown()));
      } else {
        up = coord.dataToPosition(tmpData.change(node.getUp()), x);
        down = coord.dataToPosition(tmpData.change(node.getDown()), x);
      }

      num dx = (up.radius[0] - down.radius[0]).abs();
      num dy = (up.angle[0] - down.angle[0]);

      Arc tmpArc;
      if (vertical) {
        tmpArc = arc.copy(sweepAngle: dy);
      } else {
        tmpArc = arc.copy(outRadius: dx);
      }
      node.arc = tmpArc;
    });
  }

  @override
  void onLayoutNodeForGrid(var columnNode, AxisIndex xIndex) {
    super.onLayoutNodeForGrid(columnNode, xIndex);

    GridAxis xAxis = context.findGridCoord().getAxis(xIndex.axisIndex, true);
    for (var node in columnNode.nodeList) {
      if (node.data != null) {
        if (xAxis.isCategoryAxis && !xAxis.categoryCenter) {
          node.position = node.rect.topLeft;
        } else {
          node.position = node.rect.topCenter;
        }
      } else {
        node.position = Offset(node.rect.center.dx, height);
      }
    }
  }

  @override
  void onLayoutNodeForPolar(ColumnNode<LineItemData, LineGroupData> columnNode, AxisIndex xIndex) {
    super.onLayoutNodeForPolar(columnNode, xIndex);
    for (var node in columnNode.nodeList) {
      var arc = node.arc;
      node.position = arc.centroid();
    }
  }

  @override
  void onLayoutEnd(var oldNodeList, var oldNodeMap, var newNodeList, var newNodeMap, LayoutType type) {
    super.onLayoutEnd(oldNodeList, oldNodeMap, newNodeList, newNodeMap, type);
    _updateLine(nodeList);
  }

  @override
  void onAnimatorStart(var result, LayoutType type) {
    // _updateLine(result.curList);
    super.onAnimatorStart(result, type);
  }

  @override
  void onAnimatorUpdateForGrid(var node, double t, var startMap, var endMap, LayoutType type) {}

  @override
  void onAnimatorUpdateForPolar(var node, double t, var startMap, var endMap, LayoutType type) {}

  @override
  void onAnimatorUpdateEnd(var result, double t, LayoutType type) {}

  @override
  void onAnimatorEnd(var result, LayoutType type) {}

  @override
  void onGridScrollEnd(Offset offset) {
    int start = offset.dx.abs() ~/ width;
    start += 1;
    int end = start + 2;
    for (var result in _lineList) {
      for (var areaNode in result.areaList) {
        areaNode.preCacheAreaPath(start, end, width, height, false);
      }
    }
  }

  void _updateLine(List<SingleNode<LineItemData, LineGroupData>> list) {
    Map<LineGroupData, int> groupSortMap = {};
    Map<String, int> sortMap = {};
    Map<String, Map<LineGroupData, List<SingleNode<LineItemData, LineGroupData>>>> stackMap = {};
    Map<LineGroupData, List<SingleNode<LineItemData, LineGroupData>>> normalMap = {};
    each(list, (ele, p1) {
      groupSortMap[ele.parent] = ele.groupIndex;
      if (ele.parent.isStack) {
        var stackId = ele.parent.stackId!;
        Map<LineGroupData, List<SingleNode<LineItemData, LineGroupData>>> map = stackMap[stackId] ?? {};
        stackMap[stackId] = map;
        List<SingleNode<LineItemData, LineGroupData>> tmpList = map[ele.parent] ?? [];
        map[ele.parent] = tmpList;
        tmpList.add(ele);
        int? sort = sortMap[stackId];
        if (sort == null) {
          sortMap[stackId] = ele.groupIndex;
        } else {
          if (sort > ele.groupIndex) {
            sortMap[stackId] = ele.groupIndex;
          }
        }
      } else {
        List<SingleNode<LineItemData, LineGroupData>> tmpList = normalMap[ele.parent] ?? [];
        normalMap[ele.parent] = tmpList;
        tmpList.add(ele);
      }
    });

    List<LineNode> resultList = [];

    ///先处理普通的
    normalMap.forEach((key, value) {
      if (value.isEmpty) {
        return;
      }
      var group = list.first.parent;
      var index = list.first.groupIndex;
      resultList.add(buildNormalResult(index, group, list));
    });

    ///处理堆叠数据
    List<String> keyList = List.from(stackMap.keys);
    keyList.sort((a, b) {
      return sortMap[a]!.compareTo(sortMap[b]!);
    });

    each(keyList, (key, p1) {
      Map<LineGroupData, List<SingleNode<LineItemData, LineGroupData>>> map = stackMap[key]!;
      List<LineGroupData> keyList2 = List.from(map.keys);
      keyList2.sort((a, b) {
        return groupSortMap[a]!.compareTo(groupSortMap[b]!);
      });
      for (int i = 0; i < keyList2.length; i++) {
        var group = keyList2[i];
        var cur = map[group]!;
        resultList.add(buildStackResult(cur.first.groupIndex, group, cur, resultList, i));
      }
    });

    Future(() {
      for (var result in resultList) {
        for (var areaNode in result.areaList) {
          areaNode.preCacheAreaPath(0, 3, width, height);
        }
      }
    }).then((value) {
      notifyLayoutEnd();
    });

    _lineList = resultList;
  }

  LineNode buildNormalResult(int groupIndex, LineGroupData group, List<SingleNode<LineItemData, LineGroupData>> list) {
    List<PathNode> borderList = _buildBorderPath(list);
    List<AreaNode> areaList = buildAreaPathForNormal(list);

    List<Offset?> ol = _collectOffset(list);
    Map<LineItemData, SymbolNode> nodeMap = {};
    each(ol, (off, i) {
      var data = group.data[i];
      if (data == null || off == null) {
        return;
      }
      nodeMap[data] = SymbolNode(off, data, group, groupIndex);
    });

    return LineNode(groupIndex, group, ol, borderList, areaList, nodeMap);
  }

  List<AreaNode> buildAreaPathForNormal(List<SingleNode<LineItemData, LineGroupData>> curList) {
    if (curList.length < 2) {
      return [];
    }
    var group = curList.first.parent;
    var index = curList.first.groupIndex;
    StepType? stepType = series.stepLineFun?.call(group);
    LineStyle? lineStyle = getLineStyle(group, index);
    bool smooth = stepType == null ? (lineStyle?.smooth ?? false) : false;

    List<List<Offset>> splitResult = _splitList(nodeList);
    splitResult.removeWhere((element) => element.length < 2);
    List<AreaNode> areaList = [];
    for (var itemList in splitResult) {
      Area area;
      var downList = [Offset(itemList.first.dx, height), Offset(itemList.last.dx, height)];
      if (stepType == null) {
        area = Area(itemList, downList, upSmooth: smooth, downSmooth: false);
      } else {
        Line line = _buildLine(itemList, stepType, false, []);
        area = Area(line.pointList, downList, upSmooth: smooth, downSmooth: false);
      }
      areaList.add(AreaNode(area));
    }
    return areaList;
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
    List<AreaNode> areaList = buildAreaPathForStack(nodeList, resultList, curIndex);

    List<Offset?> ol = _collectOffset(nodeList);
    Map<LineItemData, SymbolNode> nodeMap = {};
    each(ol, (off, i) {
      var data = group.data[i];
      if (data == null || off == null) {
        return;
      }
      nodeMap[data] = SymbolNode(off, data, group, groupIndex);
    });

    return LineNode(groupIndex, group, _collectOffset(nodeList), borderList, areaList, nodeMap);
  }

  List<AreaNode> buildAreaPathForStack(List<SingleNode<LineItemData, LineGroupData>> curList, List<LineNode> resultList, int curIndex) {
    if (curList.length < 2) {
      return [];
    }
    if (curIndex <= 0) {
      return buildAreaPathForNormal(curList);
    }
    var group = curList.first.parent;
    var index = curList.first.groupIndex;
    var preGroup = resultList[curIndex - 1].data;
    StepType? stepType = series.stepLineFun?.call(group);
    LineStyle? lineStyle = getLineStyle(group, index);
    bool smooth = (stepType == null) ? (lineStyle?.smooth ?? false) : false;
    StepType? preStepType = series.stepLineFun?.call(preGroup);
    LineStyle? preLineStyle = getLineStyle(preGroup, resultList[curIndex - 1].groupIndex);
    bool preSmooth = (preStepType == null) ? (preLineStyle?.smooth ?? false) : false;

    List<List<List<Offset>>> splitResult = [];
    if (series.connectNulls) {
      List<Offset> topList = [];
      List<Offset> preList = [];
      each(curList, (p0, i) {
        if (p0.data != null) {
          Offset offset = p0.position;
          topList.add(offset);
          Offset? preOffset = findBottomOffset(curIndex, resultList, i);
          preOffset ??= Offset(offset.dx, height);
          preList.add(preOffset);
        }
      });
      if (topList.length >= 2) {
        splitResult.add([topList, preList]);
      }
    } else {
      List<Offset> topList = [];
      List<Offset> preList = [];
      each(curList, (p0, i) {
        if (p0.data == null) {
          if (topList.length >= 2) {
            splitResult.add([topList, preList]);
            topList = [];
            preList = [];
          }
          return;
        }
        Offset offset = p0.position;
        topList.add(offset);
        Offset? preOffset = findBottomOffset(curIndex, resultList, i);
        preOffset ??= Offset(offset.dx, height);
        preList.add(preOffset);
      });
      if (topList.length >= 2) {
        splitResult.add([topList, preList]);
        topList = [];
        preList = [];
      }
    }

    List<AreaNode> areaList = [];

    for (var list in splitResult) {
      var topList = list[0];
      if (stepType != null) {
        topList = _buildLine(topList, stepType, false, []).pointList;
      }
      var preList = list[1];
      if (preStepType != null) {
        preList = _buildLine(preList, preStepType, false, []).pointList;
      }
      var area = Area(topList, preList, upSmooth: smooth, downSmooth: preSmooth);
      areaList.add(AreaNode(area));
    }
    return areaList;
  }

  Offset? findBottomOffset(int curIndex, List<LineNode> resultList, int arrayIndex) {
    int i = curIndex - 1;
    while (i >= 0) {
      var result = resultList[i];
      if (result.offsetList.length > arrayIndex) {
        var offset = result.offsetList[arrayIndex];
        if (offset != null) {
          return offset;
        }
      }
      i--;
    }
    return null;
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
      if (stepType == null) {
        borderList.add(PathNode(list));
      } else {
        Line line = _buildLine(list, stepType, false, []);
        borderList.add(PathNode(line.pointList));
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

  List<List<Offset>> _splitList(List<SingleNode<LineItemData, LineGroupData>> nodeList) {
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
  AreaStyle? buildAreaStyle(SingleNode<LineItemData, LineGroupData> node) {
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(node.parent, node.groupIndex);
    }
    var chartTheme = context.config.theme;
    var theme = chartTheme.lineTheme;
    if (theme.fill) {
      Color fillColor = chartTheme.getColor(node.groupIndex).withOpacity(theme.opacity);
      return AreaStyle(color: fillColor);
    }
    return null;
  }

  @override
  LineStyle? buildLineStyle(SingleNode<LineItemData, LineGroupData> node) {
    LineStyle? style = getLineStyle(node.parent, node.groupIndex);
    if (style == null || series.lineStyleFun != null) {
      return style;
    }
    return style.convert(node.status);
  }

  AreaStyle? getAreaStyle(LineGroupData group, int index) {
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(group, index);
    }
    var chartTheme = context.config.theme;
    var theme = chartTheme.lineTheme;
    if (theme.fill) {
      Color fillColor = chartTheme.getColor(index).withOpacity(theme.opacity);
      return AreaStyle(color: fillColor);
    }
    return null;
  }

  LineStyle? getLineStyle(LineGroupData group, int index) {
    if (series.lineStyleFun != null) {
      return series.lineStyleFun?.call(group, index);
    }
    var chartTheme = context.config.theme;
    var theme = chartTheme.lineTheme;
    return theme.getLineStyle(chartTheme, index);
  }
}
