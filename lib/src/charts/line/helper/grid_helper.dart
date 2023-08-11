import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/line/helper/line_helper.dart';

import '../line_node.dart';

class LineGridHelper extends GridHelper<StackItemData, LineGroupData, LineSeries> implements LineHelper {
  List<LineNode> _lineList = [];
  List<LineNode>? _cacheLineList;

  LineGridHelper(super.context, super.series);

  List<LineNode> get lineList => _lineList;

  double _animatorPercent = 1;

  @override
  List<LineNode> getLineNodeList() {
    return _lineList;
  }

  @override
  void onLayoutColumn(var axisGroup, var groupNode, AxisIndex xIndex, dynamic x,LayoutType type) {
    int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int columnCount = groupInnerCount;
    if (columnCount <= 1) {
      columnCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;
    final Rect groupRect = groupNode.rect;
    var coord = context.findGridCoord();
    each(groupNode.nodeList, (node, i) {
      var upNode = node.getUpNode();
      var downNode = node.getDownNode();
      if (upNode == null || downNode == null) {
        Logger.w("内部状态异常 无法找到 upValue 或者downValue");
        return;
      }
      dynamic upValue = getUpValue(upNode), downValue = getDownValue(downNode);
      if (vertical) {
        int yIndex = upNode.parent.yAxisIndex;
        var uo = coord.dataToPoint(yIndex, upValue, false).last;
        var downo = coord.dataToPoint(yIndex, downValue, false).first;
        node.rect = Rect.fromLTRB(groupRect.left, uo.dy, groupRect.right, downo.dy);
      } else {
        var lo = coord.dataToPoint(xIndex.axisIndex, x, true).first;
        var ro = coord.dataToPoint(xIndex.axisIndex, x, true).last;
        node.rect = Rect.fromLTRB(lo.dx, groupRect.top, ro.dx, groupRect.bottom);
      }
    });
  }

  @override
  void onLayoutNode(var columnNode, AxisIndex xIndex,LayoutType type) {
    final bool vertical = series.direction == Direction.vertical;
    final coord = findGridCoord();
    final colRect = columnNode.rect;
    GridAxis xAxis = findGridCoord().getAxis(xIndex.axisIndex, true);
    for (var node in columnNode.nodeList) {
      if (node.data == null) {
        continue;
      }
      if (vertical) {
        var uo = coord.dataToPoint(node.parent.yAxisIndex, getUpValue(node), false).last;
        node.rect = Rect.fromLTRB(colRect.left, uo.dy, colRect.right, uo.dy);
        if (xAxis.isCategoryAxis && !xAxis.categoryCenter) {
          node.position = node.rect.topLeft;
        } else {
          node.position = node.rect.topCenter;
        }
      } else {
        var uo = coord.dataToPoint(node.parent.xAxisIndex, getUpValue(node), true).last;
        node.rect = Rect.fromLTRB(uo.dx, colRect.top, uo.dx, colRect.height);
        if (xAxis.isCategoryAxis && !xAxis.categoryCenter) {
          node.position = node.rect.topRight;
        } else {
          node.position = node.rect.centerRight;
        }
      }
    }
  }

  @override
  Future<void> onLayoutEnd(var oldNodeList, var oldNodeMap, var newNodeList, var newNodeMap, LayoutType type) async {
    if (series.animation == null || type == LayoutType.none) {
      _lineList = await _layoutLineNode(newNodeList);
      _animatorPercent = 1;
    } else {
      _cacheLineList = await _layoutLineNode(newNodeList);
    }
    await super.onLayoutEnd(oldNodeList, oldNodeMap, newNodeList, newNodeMap, type);
  }

  @override
  AnimatorNode onCreateAnimatorNode(var node,DiffType diffType,LayoutType type) {
    if (diffType == DiffType.accessor) {
      return AnimatorNode(offset: node.position);
    }
    return AnimatorNode(offset: Offset(node.position.dx, height));
  }

  @override
  void onAnimatorStart(var result) {
    if (_cacheLineList != null) {
      _lineList = _cacheLineList!;
      _cacheLineList = null;
    }
    _animatorPercent = 0;
  }

  @override
  void onAnimatorUpdate(var node, double t, var startMap, var endMap) {
    _animatorPercent = t;
  }

  @override
  void onAnimatorUpdateEnd(var result, double t) {
    _animatorPercent = t;
  }

  @override
  void onAnimatorEnd(var result) {
    _animatorPercent = 1;
  }

  ///布局直线使用的数据
  Future<List<LineNode>> _layoutLineNode(List<SingleNode<StackItemData, LineGroupData>> list) async {
    Map<LineGroupData, int> groupSortMap = {};
    Map<String, int> sortMap = {};
    Map<String, Map<LineGroupData, List<SingleNode<StackItemData, LineGroupData>>>> stackMap = {};
    Map<LineGroupData, List<SingleNode<StackItemData, LineGroupData>>> normalMap = {};
    each(list, (ele, p1) {
      groupSortMap[ele.parent] = ele.groupIndex;
      if (ele.parent.isStack) {
        var stackId = ele.parent.stackId!;
        Map<LineGroupData, List<SingleNode<StackItemData, LineGroupData>>> map = stackMap[stackId] ?? {};
        stackMap[stackId] = map;
        List<SingleNode<StackItemData, LineGroupData>> tmpList = map[ele.parent] ?? [];
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
        List<SingleNode<StackItemData, LineGroupData>> tmpList = normalMap[ele.parent] ?? [];
        normalMap[ele.parent] = tmpList;
        tmpList.add(ele);
      }
    });

    List<Future<LineNode>> futureList = [];

    ///先处理普通的
    normalMap.forEach((key, value) {
      if (value.isEmpty) {
        return;
      }
      var f = Future(() {
        var group = list.first.parent;
        var index = list.first.groupIndex;
        var styleIndex = list.first.styleIndex;
        return buildNormalResult(index, styleIndex, group, list);
      });
      futureList.add(f);
    });

    List<LineNode> resultList = [];

    ///处理堆叠数据
    List<String> keyList = List.from(stackMap.keys);
    keyList.sort((a, b) {
      return sortMap[a]!.compareTo(sortMap[b]!);
    });
    each(keyList, (key, p1) {
      Map<LineGroupData, List<SingleNode<StackItemData, LineGroupData>>> map = stackMap[key]!;
      List<LineGroupData> keyList2 = List.from(map.keys);
      keyList2.sort((a, b) {
        return groupSortMap[a]!.compareTo(groupSortMap[b]!);
      });
      for (int i = 0; i < keyList2.length; i++) {
        var group = keyList2[i];
        var cur = map[group]!;
        var first = cur.first;
        resultList.add(buildStackResult(first.groupIndex, first.styleIndex, group, cur, resultList, i));
      }
    });
    for (var f in futureList) {
      resultList.add(await f);
    }
    futureList = [];
    return resultList;
  }

  LineNode buildNormalResult(int groupIndex, int styleIndex, LineGroupData group, List<SingleNode<StackItemData, LineGroupData>> list) {
    List<PathNode> borderList = _buildBorderPath(list);
    List<AreaNode> areaList = buildAreaPathForNormal(list);
    List<Offset?> ol = _collectOffset(list);
    Map<StackItemData, SymbolNode> nodeMap = {};
    each(ol, (off, i) {
      if (group.data.length <= i) {
        return;
      }
      var data = group.data[i];
      if (data == null || off == null) {
        return;
      }
      nodeMap[data] = SymbolNode(data, i, groupIndex, off, group);
    });
    return LineNode(groupIndex, styleIndex, group, ol, borderList, areaList, nodeMap);
  }

  List<AreaNode> buildAreaPathForNormal(List<SingleNode<StackItemData, LineGroupData>> curList) {
    if (curList.length < 2) {
      return [];
    }
    var group = curList.first.parent;
    final styleIndex = curList.first.groupIndex;
    StepType? stepType = series.stepLineFun?.call(group);
    LineStyle? lineStyle = buildLineStyle(null, group, styleIndex, null);
    bool smooth = stepType == null ? (lineStyle?.smooth ?? false) : false;

    List<SingleNode<StackItemData, LineGroupData>> nodeList = List.from(nodeMap.values);

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
    int styleIndex,
    LineGroupData group,
    List<SingleNode<StackItemData, LineGroupData>> nodeList,
    List<LineNode> resultList,
    int curIndex,
  ) {
    if (nodeList.isEmpty) {
      return LineNode(groupIndex, styleIndex, group, [], [], [], {});
    }
    List<PathNode> borderList = _buildBorderPath(nodeList);
    List<AreaNode> areaList = buildAreaPathForStack(nodeList, resultList, curIndex);

    List<Offset?> ol = _collectOffset(nodeList);
    Map<StackItemData, SymbolNode> nodeMap = {};
    each(ol, (off, i) {
      var data = group.data[i];
      if (data == null || off == null) {
        return;
      }
      nodeMap[data] = SymbolNode(data, i, groupIndex, off, group);
    });

    return LineNode(groupIndex, styleIndex, group, _collectOffset(nodeList), borderList, areaList, nodeMap);
  }

  List<AreaNode> buildAreaPathForStack(List<SingleNode<StackItemData, LineGroupData>> curList, List<LineNode> resultList, int curIndex) {
    if (curList.length < 2) {
      return [];
    }
    if (curIndex <= 0) {
      return buildAreaPathForNormal(curList);
    }
    var group = curList.first.parent;
    final styleIndex = curList.first.groupIndex;
    var preGroup = resultList[curIndex - 1].data;
    StepType? stepType = series.stepLineFun?.call(group);
    LineStyle? lineStyle = buildLineStyle(null, group, styleIndex, null);
    bool smooth = (stepType == null) ? (lineStyle?.smooth ?? false) : false;
    StepType? preStepType = series.stepLineFun?.call(preGroup);
    LineStyle? preLineStyle = buildLineStyle(null, preGroup, resultList[curIndex - 1].styleIndex, null);
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
  List<PathNode> _buildBorderPath(List<SingleNode<StackItemData, LineGroupData>> nodeList) {
    if (nodeList.length < 2) {
      return [];
    }
    var group = nodeList.first.parent;

    List<List<Offset>> olList = _splitList(nodeList);
    olList.removeWhere((element) => element.length < 2);
    List<PathNode> borderList = [];
    StepType? stepType = series.stepLineFun?.call(group);
    each(olList, (list, p1) {
      LineStyle? style = buildLineStyle(null, group, group.styleIndex, null);
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

  List<List<Offset>> _splitList(List<SingleNode<StackItemData, LineGroupData>> nodeList) {
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

  List<Offset?> _collectOffset(List<SingleNode<StackItemData, LineGroupData>> nodeList) {
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
  double getAnimatorPercent() {
    return _animatorPercent;
  }

  @override
  SeriesType get seriesType => SeriesType.line;
}
