import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

class LineLayoutHelper extends BaseGridLayoutHelper<LineItemData, LineGroupData, LineSeries> {
  List<LineResult> lineList = [];

  double? clipPercent;

  @override
  void onLayoutColumnForGrid(
    AxisGroup<LineItemData, LineGroupData> axisGroup,
    GroupNode<LineItemData, LineGroupData> groupNode,
    AxisIndex xIndex,
    DynamicData x,
  ) {
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
  void onLayoutColumnForPolar(
    AxisGroup<LineItemData, LineGroupData> axisGroup,
    GroupNode<LineItemData, LineGroupData> groupNode,
    AxisIndex xIndex,
    DynamicData x,
  ) {
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
  void onLayoutNodeForGrid(ColumnNode<LineItemData, LineGroupData> columnNode, AxisIndex xIndex) {
    super.onLayoutNodeForGrid(columnNode, xIndex);

    GridAxis xAxis = context.findGridCoord().getAxis(xIndex.axisIndex, true);
    for (var node in columnNode.nodeList) {
      if (node.data.data != null) {
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
  void onLayoutEnd(List<SingleNode<LineItemData, LineGroupData>> oldNodeList, List<GroupNode<LineItemData, LineGroupData>> oldGroupNodeList, Map<LineItemData, SingleNode<LineItemData, LineGroupData>> oldNodeMap, List<SingleNode<LineItemData, LineGroupData>> newNodeList, List<GroupNode<LineItemData, LineGroupData>> newGroupNodeList, Map<LineItemData, SingleNode<LineItemData, LineGroupData>> newNodeMap, LayoutType type) {
    super.onLayoutEnd(oldNodeList, oldGroupNodeList, oldNodeMap, newNodeList, newGroupNodeList, newNodeMap, type);
    if(series.animation==null){
      logPrint("不执行动画");
      _updateLine(nodeList);
    }
  }

  @override
  void onAnimatorStart(var result, LayoutType type) {
    _updateLine(result.curList);
    super.onAnimatorStart(result, type);
  }

  @override
  void onAnimatorUpdateForGrid(var node, double t, var startMap, var endMap, LayoutType type) {
    // super.onAnimatorUpdateForGrid(node, t, startMap, endMap);

    // var s = startMap[node.data]!.offset;
    // var e = endMap[node.data]!.offset;
    // _offsetTween.changeValue(s, e);
    // node.position = _offsetTween.safeGetValue(t);
    clipPercent = t;
  }

  @override
  void onAnimatorUpdateForPolar(var node, double t, var startMap, var endMap, LayoutType type) {
    // super.onAnimatorUpdateForPolar(node, t, startMap, endMap);
    // var s = startMap[node.data]!.offset;
    // var e = endMap[node.data]!.offset;
    // _offsetTween.changeValue(s, e);
    // node.position = _offsetTween.safeGetValue(t);
    clipPercent = t;
  }

  @override
  void onAnimatorUpdateEnd(var result, double t, LayoutType type) {
    //  _updateLine(result.curList);
    clipPercent = t;
  }

  @override
  void onAnimatorEnd(var result, LayoutType type) {
    // _updateLine(result.finalList);
    clipPercent = null;
  }

  void _updateLine(List<SingleNode<LineItemData, LineGroupData>> list) {
    Map<LineGroupData, List<SingleNode<LineItemData, LineGroupData>>> groupMap = {};
    Map<LineGroupData, int> groupSortMap = {};
    each(list, (node, p1) {
      List<SingleNode<LineItemData, LineGroupData>> tl = groupMap[node.data.parent] ?? [];
      groupMap[node.data.parent] = tl;
      tl.add(node);
      groupSortMap[node.data.parent] = node.data.groupIndex;
    });

    Map<String, Map<LineGroupData, List<SingleNode<LineItemData, LineGroupData>>>> stackMap = {};
    List<List<SingleNode<LineItemData, LineGroupData>>> normalList = [];

    Map<String, int> sortMap = {};

    for (var ele in list) {
      if (ele.data.parent.isStack) {
        var stackId = ele.data.parent.stackId!;
        Map<LineGroupData, List<SingleNode<LineItemData, LineGroupData>>> map = stackMap[stackId] ?? {};
        stackMap[stackId] = map;
        map[ele.data.parent] = groupMap[ele.data.parent]!;
        int? sort = sortMap[stackId];
        if (sort == null) {
          sortMap[stackId] = ele.data.groupIndex;
        } else {
          if (sort > ele.data.groupIndex) {
            sortMap[stackId] = ele.data.groupIndex;
          }
        }
      } else {
        normalList.add(groupMap[ele.data.parent]!);
      }
    }

    List<LineResult> resultList = [];

    ///先处理普通的
    each(normalList, (list, i) {
      if (list.isEmpty) {
        return;
      }
      var group = list.first.data.parent;
      var index = list.first.data.groupIndex;
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
        resultList.add(buildStackResult(cur.first.data.groupIndex, group, cur, resultList, i));
      }
    });
    lineList = resultList;
  }

  LineResult buildNormalResult(int groupIndex, LineGroupData group, List<SingleNode<LineItemData, LineGroupData>> list) {
    List<Path> borderList = _buildBorderPath(list);
    List<Path> areaList = buildAreaPathForNormal(list);
    return LineResult(groupIndex, group, _collectOffset(list), borderList, areaList);
  }

  List<Path> buildAreaPathForNormal(List<SingleNode<LineItemData, LineGroupData>> curList) {
    if (curList.length < 2) {
      return [];
    }
    var group = curList.first.data.parent;
    var index = curList.first.data.groupIndex;
    StepType? stepType = series.stepLineFun?.call(group);
    LineStyle? lineStyle = getLineStyle(group, index);
    bool smooth = stepType == null ? (lineStyle?.smooth ?? false) : false;

    if (series.connectNulls) {
      List<Offset> ol = [];
      each(curList, (p0, p1) {
        if (p0.data.data != null) {
          ol.add(p0.position);
        }
      });
      if (ol.length < 2) {
        return [];
      }
      Line line = _buildLine(ol, stepType, false, []);
      var bol = [Offset(ol.first.dx, height), Offset(ol.last.dx, height)];
      var area = Area(line.pointList, bol, upSmooth: smooth, downSmooth: false);
      return [area.toPath(true)];
    }

    List<List<Offset>> splitResult = _splitList(nodeList);
    List<Path> areaList = [];
    for (var itemList in splitResult) {
      if (itemList.length < 2) {
        continue;
      }
      Line line = _buildLine(itemList, stepType, false, []);
      var bol = [Offset(itemList.first.dx, height), Offset(itemList.last.dx, height)];
      var area = Area(line.pointList, bol, upSmooth: smooth, downSmooth: false);
      areaList.add(area.toPath(true));
    }
    return areaList;
  }

  LineResult buildStackResult(
    int groupIndex,
    LineGroupData group,
    List<SingleNode<LineItemData, LineGroupData>> nodeList,
    List<LineResult> resultList,
    int curIndex,
  ) {
    if (nodeList.isEmpty) {
      return LineResult(groupIndex, group, [], [], []);
    }
    List<Path> borderList = _buildBorderPath(nodeList);
    List<Path> areaList = buildAreaPathForStack(nodeList, resultList, curIndex);
    return LineResult(groupIndex, group, _collectOffset(nodeList), borderList, areaList);
  }

  List<Path> buildAreaPathForStack(List<SingleNode<LineItemData, LineGroupData>> curList, List<LineResult> resultList, int curIndex) {
    if (curList.length < 2) {
      return [];
    }
    if (curIndex <= 0) {
      return buildAreaPathForNormal(curList);
    }
    var group = curList.first.data.parent;
    var index = curList.first.data.groupIndex;
    var preGroup = resultList[curIndex - 1].data;
    StepType? stepType = series.stepLineFun?.call(group);
    LineStyle? lineStyle = getLineStyle(group, index);
    bool smooth = (stepType == null) ? (lineStyle?.smooth ?? false) : false;
    StepType? preStepType = series.stepLineFun?.call(preGroup);
    LineStyle? preLineStyle = getLineStyle(preGroup, resultList[curIndex - 1].groupIndex);
    bool preSmooth = (preStepType == null) ? (preLineStyle?.smooth ?? false) : false;
    List<Path> borderList = [];
    List<List<List<Offset>>> areaList = [];
    if (series.connectNulls) {
      List<Offset> topList = [];
      List<Offset> preList = [];
      each(curList, (p0, i) {
        if (p0.data.data != null) {
          Offset offset = p0.position;
          topList.add(offset);
          Offset? preOffset = findBottomOffset(curIndex, resultList, i);
          preOffset ??= Offset(offset.dx, height);
          preList.add(preOffset);
        }
      });
      if (topList.length >= 2) {
        areaList.add([topList, preList]);
      }
    } else {
      List<Offset> topList = [];
      List<Offset> preList = [];
      each(curList, (p0, i) {
        if (p0.data.data == null) {
          if (topList.length >= 2) {
            areaList.add([topList, preList]);
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
        areaList.add([topList, preList]);
        topList = [];
        preList = [];
      }

      for (var list in areaList) {
        topList = list[0];
        if (stepType != null) {
          topList = _buildLine(topList, stepType, false, []).pointList;
        }
        preList = list[1];
        if (preStepType != null) {
          preList = _buildLine(preList, preStepType, false, []).pointList;
        }

        var area = Area(topList, preList, upSmooth: smooth, downSmooth: preSmooth);
        borderList.add(area.toPath(true));
      }
    }
    return borderList;
  }

  Offset? findBottomOffset(int curIndex, List<LineResult> resultList, int arrayIndex) {
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
  List<Path> _buildBorderPath(List<SingleNode<LineItemData, LineGroupData>> nodeList) {
    if (nodeList.length < 2) {
      return [];
    }
    var group = nodeList.first.data.parent;
    var index = nodeList.first.data.groupIndex;

    List<Path> borderList = [];
    LineStyle? lineStyle = getLineStyle(group, index);
    bool smooth = lineStyle?.smooth ?? false;
    List<num> dash = lineStyle?.dash ?? [];
    if (series.connectNulls) {
      List<Offset> offsetList = [];
      each(nodeList, (p0, p1) {
        if (p0.data.wrap.data != null) {
          offsetList.add(p0.position);
        }
      });
      if (offsetList.length < 2) {
        return borderList;
      }
      StepType? type = series.stepLineFun?.call(group);
      Line line = _buildLine(offsetList, type, smooth, dash);
      borderList.add(line.toPath(false));
      return borderList;
    }
    List<Offset> tmpList = [];
    StepType? type = series.stepLineFun?.call(group);
    each(nodeList, (p0, p1) {
      if (p0.data.wrap.data != null) {
        tmpList.add(p0.position);
      } else {
        if (tmpList.length >= 2) {
          borderList.add(_buildLine(tmpList, type, smooth, dash).toPath(false));
        }
        tmpList = [];
      }
    });
    if (tmpList.length >= 2) {
      borderList.add(_buildLine(tmpList, type, smooth, dash).toPath(false));
    }
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
      if (node.data.data != null) {
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
      if (node.data.data != null) {
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
      return series.areaStyleFun?.call(node.data.parent, node.data.groupIndex);
    }
    var chartTheme = context.config.theme;
    var theme = chartTheme.lineTheme;
    if (theme.fill) {
      Color fillColor = chartTheme.getColor(node.data.groupIndex).withOpacity(theme.opacity);
      return AreaStyle(color: fillColor);
    }
    return null;
  }

  @override
  LineStyle? buildLineStyle(SingleNode<LineItemData, LineGroupData> node) {
    LineStyle? style = getLineStyle(node.data.parent, node.data.groupIndex);
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

class LineResult {
  final int groupIndex;
  final LineGroupData data;
  final List<Offset?> offsetList;
  final List<Path> borderPathList;
  final List<Path> areaPathList;

  AreaStyle? areaStyle;
  LineStyle? lineStyle;

  LineResult(this.groupIndex, this.data, this.offsetList, this.borderPathList, this.areaPathList);
}
