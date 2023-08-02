import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/line/helper/line_helper.dart';

import '../line_node.dart';

class LineGridHelper extends BaseGridLayoutHelper<LineItemData, LineGroupData, LineSeries> implements LineHelper {
  List<LineNode> _lineList = [];

  List<LineNode> get lineList => _lineList;

  double _animatorPercent = 1;

  @override
  List<SingleNode<LineItemData, LineGroupData>> getPageData(List<int> pages) {
    return [];
  }

  @override
  List<SingleNode<LineItemData, LineGroupData>> getNeedShowData() {
    return [];
  }

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
  void onLayoutNode(var columnNode, AxisIndex xIndex) {
    super.onLayoutNode(columnNode, xIndex);
    GridAxis xAxis = findGridCoord().getAxis(xIndex.axisIndex, true);
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
  Future<void> onLayoutEnd(var oldNodeList, var oldNodeMap, var newNodeList, var newNodeMap, LayoutType type) async {
    super.onLayoutEnd(oldNodeList, oldNodeMap, newNodeList, newNodeMap, type);
    _lineList = await _layoutLineNode(newNodeList);
  }

  @override
  Future<void> splitData(List<SingleNode<LineItemData, LineGroupData>> list) async {
    ///Line 不需要按页进行划分
  }

  @override
  SingleNode<LineItemData, LineGroupData> onCreateAnimatorObj(var data, var node, bool newData, LayoutType type) {
    return node;
  }

  @override
  void onAnimatorStart(var result, LayoutType type) {
    _animatorPercent = 0;
  }

  @override
  void onAnimatorUpdate(var node, double t, var startMap, var endMap, LayoutType type) {
    _animatorPercent = t;
  }

  @override
  void onAnimatorUpdateEnd(var result, double t, LayoutType type) {
    _animatorPercent = t;
  }

  @override
  void onAnimatorEnd(var result, LayoutType type) {
    _animatorPercent = 1;
  }

  @override
  void onGridScrollEnd(Offset offset) {}

  ///布局直线使用的数据
  Future<List<LineNode>> _layoutLineNode(List<SingleNode<LineItemData, LineGroupData>> list) async {
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

    List<Future<LineNode>> futureList = [];

    ///先处理普通的
    normalMap.forEach((key, value) {
      if (value.isEmpty) {
        return;
      }
      var f = Future(() {
        var group = list.first.parent;
        var index = list.first.groupIndex;
        return buildNormalResult(index, group, list);
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
    for (var f in futureList) {
      resultList.add(await f);
    }
    futureList = [];
    return resultList;
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
    LineStyle? lineStyle = buildLineStyle(null, group, index, null);
    bool smooth = stepType == null ? (lineStyle?.smooth ?? false) : false;

    List<SingleNode<LineItemData, LineGroupData>> nodeList = List.from(nodeMap.values);

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
    LineStyle? lineStyle = buildLineStyle(null, group, index, null);
    bool smooth = (stepType == null) ? (lineStyle?.smooth ?? false) : false;
    StepType? preStepType = series.stepLineFun?.call(preGroup);
    LineStyle? preLineStyle = buildLineStyle(null, preGroup, resultList[curIndex - 1].groupIndex, null);
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
  AreaStyle? buildAreaStyle(LineItemData? data, LineGroupData group, int groupIndex, Set<ViewState>? status) {
    if (series.areaStyleFun != null) {
      return series.areaStyleFun?.call(group, groupIndex);
    }
    var chartTheme = context.config.theme;
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
      return series.lineStyleFun?.call(group, groupIndex);
    }
    var chartTheme = context.config.theme;
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
