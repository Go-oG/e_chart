import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/animation.dart';

///适用于GridCoord坐标系的布局帮助者
abstract class StackGridHelper<T extends StackItemData, P extends StackGroupData<T>, S extends StackSeries<T, P>>
    extends BaseStackLayoutHelper<T, P, S> {
  ///根据给定的页码编号，返回对应的数据
  Map<int, List<SingleNode<T, P>>> _pageMap = {};

  StackGridHelper(super.context, super.series);

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
  void onLayoutNode(ColumnNode<T, P> columnNode, AxisIndex xIndex) {
    final num up = columnNode.nodeList[columnNode.nodeList.length - 1].up;
    final num down = columnNode.nodeList.first.down;
    final num diff = up - down;
    final bool vertical = series.direction == Direction.vertical;

    final Rect rect = columnNode.rect;
    final double size = vertical ? rect.height : rect.width;
    double bottom = rect.bottom;
    double left = rect.left;
    for (var node in columnNode.nodeList) {
      num percent = (node.up - node.down) / diff;
      double length = percent * size;
      if (vertical) {
        bottom = bottom - length;
        node.rect = Rect.fromLTWH(rect.left, bottom, rect.width, length);
      } else {
        node.rect = Rect.fromLTWH(left, rect.top, length, rect.height);
        left += length;
      }
      node.position = node.rect.center;
    }
  }

  @override
  MarkPointNode? onLayoutMarkPoint(MarkPoint markPoint, P group, Map<T, SingleNode<T, P>> newNodeMap) {
    var valueType = markPoint.data.valueType;
    if (valueType != null || markPoint.data.data != null) {
      return super.onLayoutMarkPoint(markPoint, group, newNodeMap);
    }
    var gridCoord = findGridCoord();
    bool vertical = series.direction == Direction.vertical;
    if (markPoint.data.coord != null) {
      var coord = markPoint.data.coord!;
      var x = coord[0].convert(gridCoord.getAxisLength(group.xAxisIndex, true));
      var xr = x / gridCoord.getAxisLength(group.xAxisIndex, true);
      var y = coord[1].convert(gridCoord.getAxisLength(group.yAxisIndex, false));
      var yr = y / gridCoord.getAxisLength(group.yAxisIndex, false);
      var dd = vertical
          ? gridCoord.getScale(group.yAxisIndex, false).convertRatio(yr)
          : gridCoord.getScale(group.xAxisIndex, true).convertRatio(xr);
      var node = MarkPointNode(markPoint, dd.toData());
      node.offset = Offset(x, y);
      return node;
    }
    return null;
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
      onAnimatorStart(diffResult);
    };
    doubleTween.endListener = () {
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
