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
        path = data.borderStyle.buildPath(upList);
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
  // List<LineNode> _layoutLineNode(List<StackData<StackItemData, LineGroupData>> list) {
  //   Map<LineGroupData, int> groupSortMap = {};
  //   Map<String, int> sortMap = {};
  //   Map<String, Map<LineGroupData, List<StackData<StackItemData, LineGroupData>>>> stackMap = {};
  //   Map<LineGroupData, List<StackData<StackItemData, LineGroupData>>> normalMap = {};
  //   each(list, (ele, p1) {
  //     groupSortMap[ele.parent] = ele.groupIndex;
  //     if (ele.parent.isStack) {
  //       var stackId = ele.parent.stackId!;
  //       Map<LineGroupData, List<StackData<StackItemData, LineGroupData>>> map = stackMap[stackId] ?? {};
  //       stackMap[stackId] = map;
  //       List<StackData<StackItemData, LineGroupData>> tmpList = map[ele.parent] ?? [];
  //       map[ele.parent] = tmpList;
  //       tmpList.add(ele);
  //       int? sort = sortMap[stackId];
  //       if (sort == null) {
  //         sortMap[stackId] = ele.groupIndex;
  //       } else {
  //         if (sort > ele.groupIndex) {
  //           sortMap[stackId] = ele.groupIndex;
  //         }
  //       }
  //     } else {
  //       List<StackData<StackItemData, LineGroupData>> tmpList = normalMap[ele.parent] ?? [];
  //       normalMap[ele.parent] = tmpList;
  //       tmpList.add(ele);
  //     }
  //   });
  //
  //   List<LineNode> resultList = [];
  //
  //   ///先处理普通的
  //   normalMap.forEach((key, value) {
  //     if (value.isEmpty) {
  //       return;
  //     }
  //     var group = list.first.parent;
  //     var index = list.first.groupIndex;
  //     resultList.add(buildNormalResult(index, group, list));
  //   });
  //
  //   ///处理堆叠数据
  //   List<String> keyList = List.from(stackMap.keys);
  //   keyList.sort((a, b) {
  //     return sortMap[a]!.compareTo(sortMap[b]!);
  //   });
  //   each(keyList, (key, p1) {
  //     Map<LineGroupData, List<StackData<StackItemData, LineGroupData>>> map = stackMap[key]!;
  //     List<LineGroupData> keyList2 = List.from(map.keys);
  //     keyList2.sort((a, b) {
  //       return groupSortMap[a]!.compareTo(groupSortMap[b]!);
  //     });
  //     for (int i = 0; i < keyList2.length; i++) {
  //       var group = keyList2[i];
  //       var cur = map[group]!;
  //       var first = cur.first;
  //       resultList.add(buildStackResult(first.groupIndex, group, cur, resultList, i));
  //     }
  //   });
  //   return resultList;
  // }
  //
  // LineNode buildNormalResult(int groupIndex, LineGroupData group, List<StackData<StackItemData, LineGroupData>> list) {
  //   List<OptLinePath> borderList = _buildBorderPath(list);
  //   List<AreaNode> areaList = buildAreaPathForNormal(list);
  //   List<Offset?> ol = _collectOffset(list);
  //   Map<StackData, LineSymbolNode> nodeMap = {};
  //   each(ol, (off, i) {
  //     if (group.data.length <= i) {
  //       return;
  //     }
  //     var data = group.data[i];
  //     if (off == null) {
  //       return;
  //     }
  //     var symbol = getSymbol(data, group);
  //     if (symbol != null) {
  //       nodeMap[data] = LineSymbolNode(group, data, symbol, i, groupIndex)..center = off;
  //     }
  //   });
  //   return LineNode(group, ol, borderList, areaList, nodeMap);
  // }

  // List<AreaNode> buildAreaPathForNormal(List<StackData<StackItemData, LineGroupData>> curList) {
  //   if (curList.length < 2) {
  //     return [];
  //   }
  //   var group = curList.first.parent;
  //   var stepType = series.stepLineFun?.call(group);
  //   var lineStyle = curList.first.borderStyle;
  //
  //   num smooth = stepType == null ? lineStyle.smooth : 0;
  //
  //   List<StackData<StackItemData, LineGroupData>> nodeList = this.nodeList;
  //
  //   var splitResult = _splitList(nodeList);
  //   splitResult.removeWhere((element) => element.length < 2);
  //   List<AreaNode> areaList = [];
  //   for (var itemList in splitResult) {
  //     Area area;
  //     var first = itemList.first;
  //     var last = itemList.last;
  //     var downList = [Offset(first.position.dx, height), Offset(last.position.dx, height)];
  //
  //     List<Offset> ol = List.from(itemList.map((e) => e.position));
  //     if (stepType == null) {
  //       area = Area(ol, downList, upSmooth: smooth, downSmooth: 0);
  //     } else {
  //       Line line = _buildLine(ol, stepType, 0, []);
  //       area = Area(line.pointList, downList, upSmooth: smooth, downSmooth: 0);
  //     }
  //     areaList.add(AreaNode(area));
  //   }
  //   return areaList;
  // }

  // LineNode buildStackResult(
  //   int groupIndex,
  //   LineGroupData group,
  //   List<StackData<StackItemData, LineGroupData>> nodeList,
  //   List<LineNode> resultList,
  //   int curIndex,
  // ) {
  //   if (nodeList.isEmpty) {
  //     return LineNode([], [], [], {});
  //   }
  //   List<OptLinePath> borderList = _buildBorderPath(nodeList);
  //   List<AreaNode> areaList = buildAreaPathForStack(nodeList, resultList, curIndex);
  //
  //   List<Offset?> ol = _collectOffset(nodeList);
  //   Map<StackData, LineSymbolNode> nodeMap = {};
  //   each(ol, (off, i) {
  //     var data = group.data[i];
  //     if (off == null) {
  //       return;
  //     }
  //     var symbol = getSymbol(data, group);
  //     if (symbol != null) {
  //       nodeMap[data] = LineSymbolNode(group, data, symbol, i, groupIndex)..center = off;
  //     }
  //   });
  //
  //   return LineNode(groupIndex, group, _collectOffset(nodeList), borderList, areaList, nodeMap);
  // }

  // List<AreaNode> buildAreaPathForStack(
  //     List<StackData<StackItemData, LineGroupData>> curList, List<LineNode> resultList, int curIndex) {
  //   if (curList.length < 2) {
  //     return [];
  //   }
  //   if (curIndex <= 0) {
  //     return buildAreaPathForNormal(curList);
  //   }
  //   var group = curList.first.parent;
  //   var preGroup = resultList[curIndex - 1].data;
  //   LineType? stepType = series.stepLineFun?.call(group);
  //   var lineStyle = curList.first.borderStyle;
  //   num smooth = (stepType == null) ? (lineStyle.smooth) : 0;
  //   LineType? preStepType = series.stepLineFun?.call(preGroup);
  //   var preLineStyle = resultList[curIndex - 1].lineStyle;
  //   num preSmooth = (preStepType == null) ? (preLineStyle.smooth) : 0;
  //
  //   List<List<List<Offset>>> splitResult = [];
  //   if (series.connectNulls) {
  //     List<Offset> topList = [];
  //     List<Offset> preList = [];
  //     each(curList, (p0, i) {
  //       if (p0.dataIsNotNull) {
  //         Offset offset = p0.position;
  //         topList.add(offset);
  //         Offset? preOffset = findBottomOffset(curIndex, resultList, i);
  //         preOffset ??= Offset(offset.dx, height);
  //         preList.add(preOffset);
  //       }
  //     });
  //     if (topList.length >= 2) {
  //       splitResult.add([topList, preList]);
  //     }
  //   } else {
  //     List<Offset> topList = [];
  //     List<Offset> preList = [];
  //     each(curList, (p0, i) {
  //       if (p0.dataIsNotNull) {
  //         if (topList.length >= 2) {
  //           splitResult.add([topList, preList]);
  //           topList = [];
  //           preList = [];
  //         }
  //         return;
  //       }
  //       Offset offset = p0.position;
  //       topList.add(offset);
  //       Offset? preOffset = findBottomOffset(curIndex, resultList, i);
  //       preOffset ??= Offset(offset.dx, height);
  //       preList.add(preOffset);
  //     });
  //     if (topList.length >= 2) {
  //       splitResult.add([topList, preList]);
  //       topList = [];
  //       preList = [];
  //     }
  //   }
  //   List<AreaNode> areaList = [];
  //   for (var list in splitResult) {
  //     var topList = list[0];
  //     if (stepType != null) {
  //       topList = _buildLine(topList, stepType, 0, []).pointList;
  //     }
  //     var preList = list[1];
  //     if (preStepType != null) {
  //       preList = _buildLine(preList, preStepType, 0, []).pointList;
  //     }
  //     var area = Area(topList, preList, upSmooth: smooth, downSmooth: preSmooth);
  //     areaList.add(AreaNode(area));
  //   }
  //   return areaList;
  // }

  // Offset? findBottomOffset(int curIndex, List<LineNode> resultList, int arrayIndex) {
  //   int i = curIndex - 1;
  //   while (i >= 0) {
  //     var result = resultList[i];
  //     if (result.offsetList.length > arrayIndex) {
  //       var offset = result.offsetList[arrayIndex];
  //       if (offset != null) {
  //         return offset;
  //       }
  //     }
  //     i--;
  //   }
  //   return null;
  // }

  // ///公用部分
  // List<OptLinePath> _buildBorderPath(List<StackData<StackItemData, LineGroupData>> nodeList) {
  //   if (nodeList.length < 2) {
  //     return [];
  //   }
  //   var group = nodeList.first.parent;
  //
  //   var olList = _splitList(nodeList);
  //   olList.removeWhere((element) => element.length < 2);
  //   List<OptLinePath> borderList = [];
  //   var stepType = series.stepLineFun?.call(group);
  //   each(olList, (list, p1) {
  //     var style = list.first.borderStyle;
  //     num smooth = stepType != null ? 0 : style.smooth;
  //     List<Offset> ol = List.from(list.map((e) => e.position));
  //     if (stepType == null) {
  //       borderList.add(OptLinePath.build(ol, smooth, style.dash));
  //     } else {
  //       Line line = _buildLine(ol, stepType, 0, []);
  //       borderList.add(OptLinePath.build(line.pointList, smooth, style.dash));
  //     }
  //   });
  //   return borderList;
  // }

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
      List<StackData<StackItemData, LineGroupData>> nodeList) {
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
}
