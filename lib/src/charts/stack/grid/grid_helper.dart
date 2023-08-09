import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

///适用于GridCoord坐标系的布局帮助者
abstract class GridHelper<T extends StackItemData, P extends StackGroupData<T>, S extends StackSeries<T, P>> extends StackHelper<T, P, S> {
  ///根据给定的页码编号，返回对应的数据
  Map<int, List<SingleNode<T, P>>> _pageMap = {};

  GridHelper(super.context, super.series);

  List<SingleNode<T, P>> getPageData(List<int> pages) {
    List<SingleNode<T, P>> list = [];
    final map = _pageMap;
    for (int page in pages) {
      var tmp = map[page];
      if (tmp == null || tmp.isEmpty) {
        continue;
      }
      list.addAll(tmp);
    }
    return list;
  }

  ///获取要显示的数据
  List<SingleNode<T, P>> getNeedShowData() {
    Offset offset = getTranslation();
    int startIndex, endIndex;
    bool vertical = series.direction == Direction.vertical;
    double size = vertical ? width : height;
    double scroll = vertical ? offset.dx : offset.dy;
    scroll = scroll.abs();
    startIndex = scroll ~/ size;
    endIndex = (scroll + size) ~/ size;
    endIndex += 1;
    List<int> pages = List.generate(endIndex - startIndex, (index) => index + startIndex);
    return getPageData(pages);
  }

  @override
  void onLayoutGroup(GroupNode<T, P> groupNode, AxisIndex xIndex, DynamicData x) {
    bool vertical = series.direction == Direction.vertical;
    var coord = findGridCoord();
    int yIndex = groupNode.getYAxisIndex();
    int xAxisIndex = xIndex.axisIndex;
    final up = groupNode.nodeList.first.getUp();
    if (vertical) {
      var rect = coord.dataToRect(xAxisIndex, x, yIndex, up.toData());
      groupNode.rect = Rect.fromLTWH(rect.left, 0, rect.width, height);
    } else {
      var rect = coord.dataToRect(xAxisIndex, up.toData(), yIndex, x);
      groupNode.rect = Rect.fromLTWH(0, rect.top, width, rect.height);
    }
  }

  @override
  void onLayoutColumn(var axisGroup, var groupNode, AxisIndex xIndex, DynamicData x) {
    final int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int colGapCount = groupInnerCount - 1;
    if (colGapCount < 1) {
      colGapCount = 0;
    }
    final bool vertical = series.direction == Direction.vertical;
    final Rect groupRect = groupNode.rect;
    final num groupSize = vertical ? groupRect.width : groupRect.height;

    double groupGap = series.groupGap.convert(groupSize) * 2;
    double columnGap = series.columnGap.convert(groupSize);
    double allGap = groupGap + colGapCount * columnGap;

    double canUseSize = groupSize - allGap;
    if (canUseSize < 0) {
      canUseSize = groupSize.toDouble();
    }
    double allBarSize = 0;

    ///计算Group占用的大小
    List<double> sizeList = [];
    each(groupNode.nodeList, (node, i) {
      var first = node.nodeList.first;
      var groupData = first.parent;
      double tmpSize;
      if (groupData.barSize != null) {
        tmpSize = groupData.barSize!.convert(canUseSize);
      } else {
        tmpSize = canUseSize / groupInnerCount;
        if (groupData.barMaxSize != null) {
          var s = groupData.barMaxSize!.convert(canUseSize);
          if (tmpSize > s) {
            tmpSize = s;
          }
        }
        if (groupData.barMinSize != null) {
          var size = groupData.barMinSize!.convert(canUseSize);
          if (tmpSize < size) {
            tmpSize = size;
          }
        }
      }
      allBarSize += tmpSize;
      sizeList.add(tmpSize);
    });

    if (allBarSize + allGap > groupSize) {
      double k = groupSize / (allBarSize + allGap);
      groupGap *= k;
      columnGap *= k;
      allBarSize *= k;
      allGap *= k;
      for (int i = 0; i < sizeList.length; i++) {
        sizeList[i] = sizeList[i] * k;
      }
    }

    double offset = vertical ? groupRect.left : groupRect.top;
    offset += groupGap * 0.5;

    each(groupNode.nodeList, (node, i) {
      if (node.nodeList.isEmpty) {
        return;
      }
      var parent = node.nodeList.first.parent;
      int yIndex = parent.yAxisIndex;
      var coord = findGridCoord();
      var upNode = node.getUpNode();
      var downNode = node.getDownNode();
      if (upNode == null || downNode == null) {
        Logger.w("内部状态异常 无法找到 upValue 或者downValue");
        return;
      }
      DynamicData upValue = getUpValue(upNode), downValue = getDownValue(downNode);
      if (vertical) {
        var uo = coord.dataToPoint(yIndex, upValue, false).last;
        var downo = coord.dataToPoint(yIndex, downValue, false).first;
        node.rect = Rect.fromLTRB(offset, uo.dy, offset + sizeList[i], downo.dy);
        offset += sizeList[i] + columnGap;
      } else {
        var lo = coord.dataToPoint(xIndex.axisIndex, x, true).first;
        var ro = coord.dataToPoint(xIndex.axisIndex, x, true).last;
        node.rect = Rect.fromLTRB(lo.dx, offset, ro.dx, offset + sizeList[i]);
        offset += sizeList[i] + columnGap;
      }
    });
  }

  @override
  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex) {
    final bool vertical = series.direction == Direction.vertical;
    final coord = findGridCoord();
    final colRect = columnNode.rect;
    for (var node in columnNode.nodeList) {
      if (vertical) {
        var uo = coord.dataToPoint(node.parent.yAxisIndex, getUpValue(node), false).last;
        var downo = coord.dataToPoint(node.parent.yAxisIndex, getDownValue(node), false).first;
        node.rect = Rect.fromLTRB(colRect.left, uo.dy, colRect.right, downo.dy);
      } else {
        var uo = coord.dataToPoint(node.parent.xAxisIndex, getUpValue(node), true).last;
        var downo = coord.dataToPoint(node.parent.xAxisIndex, getDownValue(node), true).first;
        node.rect = Rect.fromLTRB(downo.dx, colRect.top, uo.dx, colRect.height);
      }
      node.position = node.rect.center;
    }
  }

  DynamicData getUpValue(SingleNode<T, P> node) {
    return node.up.toData();
  }

  DynamicData getDownValue(SingleNode<T, P> node) {
    return node.down.toData();
  }

  @override
  Future<void> onLayoutEnd(var oldNodeList, var oldNodeMap, var newNodeList, var newNodeMap, LayoutType type) async {
    List<SingleNode<T, P>> oldShowData = getNeedShowData();
    _pageMap = await splitData(newNodeList);
    List<SingleNode<T, P>> showData = getNeedShowData();

    ///动画
    DiffResult2<SingleNode<T, P>, AnimatorNode, T> diffResult = DiffUtil.diff3(oldShowData, showData, (p0) => p0.data!, (b, c) {
      return onCreateAnimatorNode(b, c);
    });
    final startMap = diffResult.startMap;
    final endMap = diffResult.endMap;
    ChartDoubleTween doubleTween = ChartDoubleTween.fromValue(0, 1, props: series.animatorProps);
    doubleTween.startListener = () {
      Map<T, SingleNode<T, P>> map = {};
      diffResult.startMap.forEach((key, value) {
        if (key.data != null) {
          map[key.data!] = key;
        }
      });
      showNodeMap = map;
      updateNodeMap(map);
      onAnimatorStart(diffResult);
    };
    doubleTween.endListener = () {
      Map<T, SingleNode<T, P>> map = {};
      for (var value in diffResult.endList) {
        if (value.data != null) {
          map[value.data!] = value;
        }
      }
      showNodeMap = map;
      updateNodeMap(newNodeMap);
      onAnimatorEnd(diffResult);
      notifyLayoutEnd();
    };
    doubleTween.addListener(() {
      double t = doubleTween.value;
      each(diffResult.startList, (node, p1) {
        onAnimatorUpdate(node, t, startMap, endMap);
      });
      onAnimatorUpdateEnd(diffResult, t);
      notifyLayoutUpdate();
    });
    doubleTween.start(context, type == LayoutType.update);
  }

  final int thresholdSize = 2000;

  ///按页拆分数据(以便后续优化)
  ///该方法由[onLayoutEnd]调用
  Future<Map<int, List<SingleNode<T, P>>>> splitData(List<SingleNode<T, P>> list) async {
    if (list.length <= thresholdSize) {
      return splitDataByPage(list, 0, list.length);
    }
    Map<int, List<SingleNode<T, P>>> pageMap = {};
    int l = list.length;
    int c = l ~/ thresholdSize;
    if (c % thresholdSize != 0) {
      c++;
    }
    List<Future<Map<int, List<SingleNode<T, P>>>>> futureList = [];
    for (int i = 0; i < c; i++) {
      int s = i * thresholdSize;
      int e = (i + 1) * thresholdSize;
      if (e > l) {
        e = l;
      }
      futureList.add(Future(() {
        return splitDataByPage(list, s, e);
      }));
    }
    for (var fu in futureList) {
      var map = await fu;
      map.forEach((key, value) {
        if (!pageMap.containsKey(key)) {
          pageMap[key] = value;
        } else {
          List<SingleNode<T, P>> tmpList = pageMap[key]!;
          tmpList.addAll(value);
        }
      });
    }
    return pageMap;
  }

  Map<int, List<SingleNode<T, P>>> splitDataByPage(List<SingleNode<T, P>> list, int start, int end) {
    Map<int, List<SingleNode<T, P>>> resultMap = {};
    double w = width;
    double h = height;
    bool vertical = series.direction == Direction.vertical;
    double size = vertical ? w : h;
    for (int i = start; i < end; i++) {
      var node = list[i];
      Rect rect = node.rect;
      double s = vertical ? rect.left : rect.top;
      int index = s ~/ size;
      List<SingleNode<T, P>> tmpList = resultMap[index] ?? [];
      resultMap[index] = tmpList;
      tmpList.add(node);
    }
    return resultMap;
  }

  @override
  AnimatorNode onCreateAnimatorNode(SingleNode<T, P> node, DiffType type) {
    final Rect rect = node.rect;
    if (type == DiffType.accessor) {
      return AnimatorNode(rect: rect, offset: rect.center);
    }
    Rect rr;
    if (series.direction == Direction.vertical) {
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        rr = Rect.fromLTWH(rect.left, height, rect.width, 0);
      } else {
        rr = Rect.fromLTWH(rect.left, rect.bottom, rect.width, 0);
      }
    } else {
      if (series.animatorStyle == GridAnimatorStyle.expand) {
        rr = Rect.fromLTWH(0, rect.top, 0, rect.height);
      } else {
        rr = Rect.fromLTWH(rect.left, rect.top, 0, rect.height);
      }
    }
    return AnimatorNode(rect: rr, offset: rr.center);
  }

  @override
  void onAnimatorUpdate(SingleNode<T, P> node, double t, var startMap, var endMap) {
    var s = startMap[node]!.rect;
    var e = endMap[node]!.rect;
    if (s == null || e == null) {
      return;
    }
    Rect r;
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      r = Rect.lerp(s, e, t)!;
    } else {
      if (series.direction == Direction.vertical) {
        r = Rect.fromLTRB(e.left, e.bottom - e.height * t, e.right, e.bottom);
      } else {
        r = Rect.fromLTWH(e.left, e.top, e.width * t, e.height);
      }
    }
    node.rect = r;
  }

  @override
  void onGridScrollChange(Offset offset) {
    super.onGridScrollChange(offset);
    var list = getNeedShowData();
    Map<T, SingleNode<T, P>> map = {};
    for (var node in list) {
      if (node.data != null) {
        map[node.data!] = node;
      }
    }
    showNodeMap = map;
  }

  @override
  SingleNode<T, P>? findNode(Offset offset) {
    for (var ele in getNeedShowData()) {
      if (ele.rect.contains(offset)) {
        return ele;
      }
    }
    return null;
  }

  @override
  Offset getTranslation() {
    return findGridCoord().getTranslation();
  }

  @override
  CoordSystem get coordSystem => CoordSystem.grid;
}
