import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';

class LineLayoutHelper extends BaseGridLayoutHelper<LineItemData, LineGroupData, LineSeries> {
  List<LineResult> lineList = [];

  @override
  void onLayoutGroupColumn(AxisGroup<LineItemData, LineGroupData> axisGroup, GroupNode<LineItemData, LineGroupData> groupNode,
      GridCoord coord, AxisIndex xIndex, DynamicData x) {
    int groupInnerCount = axisGroup.getColumnCount(xIndex);
    int columnCount = groupInnerCount;
    if (columnCount <= 1) {
      columnCount = 0;
    }

    final bool vertical = series.direction == Direction.vertical;
    final Rect rect = groupNode.rect;

    DynamicData tmpData = DynamicData(0);
    each(groupNode.nodeList, (node, i) {
      int yIndex = node.data.data.first.parent.yAxisIndex ?? series.yAxisIndex;
      num up = node.getUp();

      ///确定上界和下界
      Rect r1 = coord.dataToRect(xIndex.index, x, yIndex, tmpData.change(up));
      Rect r2 = coord.dataToRect(xIndex.index, x, yIndex, tmpData.change(node.getDown()));

      double h = (r1.top - r2.top).abs();
      double w = (r1.left - r2.left).abs();
      Rect tmpRect;
      if (vertical) {
        tmpRect = Rect.fromLTWH(rect.left, rect.bottom - h, rect.width, h);
      } else {
        tmpRect = Rect.fromLTWH(rect.left, rect.top, w, rect.height);
      }
      node.rect = tmpRect;
    });
  }

  @override
  void onLayoutColumn(ColumnNode<LineItemData, LineGroupData> columnNode, GridCoord coord, AxisIndex xIndex, DynamicData x) {
    super.onLayoutColumn(columnNode, coord, xIndex, x);
    GridAxis xAxis = coord.getAxis(xIndex.index, true);
    for (var node in columnNode.nodeList) {
      if (xAxis.isCategoryAxis && !xAxis.categoryCenter) {
        node.position = node.rect.topLeft;
      } else {
        node.position = node.rect.topCenter;
      }
    }
  }

  @override
  SingleNode<LineItemData, LineGroupData> onCreateAnimatorObj(
      LineItemData data, SingleNode<LineItemData, LineGroupData> node, bool newData) {
    SingleNode<LineItemData, LineGroupData> rn = super.onCreateAnimatorObj(data, node, newData);
    Offset pos = node.position;
    Offset offset;
    if (series.animatorStyle == GridAnimatorStyle.expand) {
      offset = Offset(pos.dx, height);
    } else {
      offset = Offset(pos.dx, rect.bottom);
    }
    rn.position = offset;
    return rn;
  }

  final OffsetTween _offsetTween = OffsetTween(Offset.zero, Offset.zero);

  @override
  void onAnimatorUpdate(
    SingleNode<LineItemData, LineGroupData> node,
    double t,
    Map<LineItemData, MapNode> startMap,
    Map<LineItemData, MapNode> endMap,
  ) {
    super.onAnimatorUpdate(node, t, startMap, endMap);
    var s = startMap[node.data.data]!.offset;
    var e = endMap[node.data.data]!.offset;
    _offsetTween.changeValue(s, e);
    node.position = _offsetTween.safeGetValue(t);
  }

  @override
  void onAnimatorUpdateEnd(DiffResult<SingleNode<LineItemData, LineGroupData>, LineItemData> result) {
    _updateLine(result.curList);
  }

  @override
  void onAnimatorEnd(DiffResult<SingleNode<LineItemData, LineGroupData>, LineItemData> result) {
    _updateLine(result.finalList);
  }

  void _updateLine(List<SingleNode<LineItemData, LineGroupData>> list) {
    //<stackId>
    Map<String, List<LineGroupData>> stackMap = {};
    List<LineGroupData> normalList = [];
    Map<LineItemData, SingleNode<LineItemData, LineGroupData>> nodeMap = {};
    each(list, (node, p1) {
      var group = node.data.parent;
      if (group.isStack) {
        List<LineGroupData> dl = stackMap[group.stackId!] ?? [];
        stackMap[group.stackId!] = dl;
        dl.add(group);
      } else {
        normalList.add(group);
      }
      nodeMap[node.data.data] = node;
    });
    List<LineResult> lineList = [];
    List<Offset> bottomList = [Offset(0, height), Offset(width, height)];
    each(normalList, (group, i) {
      if (group.data.isEmpty) {
        return;
      }
      List<Offset> ol = [];
      each(group.data, (item, i) {
        var node = nodeMap[item]!;
        ol.add(node.position);
      });
      lineList.add(generatePath(ol, bottomList, true, group, i));
    });
    stackMap.forEach((key, value) {
      List<List<Offset>> dl = [];
      each(value, (group, i) {
        if (group.data.isEmpty) {
          return;
        }
        List<Offset> ol = [];
        dl.add(ol);
        each(group.data, (item, p) {
          var node = nodeMap[item]!;
          ol.add(node.position);
        });
        if (i == 0) {
          lineList.add(generatePath(ol, bottomList, true, group, i));
        } else {
          lineList.add(generatePath(ol, lineList[i - 1].offsetList, false, group, i));
        }
      });
    });
    this.lineList = lineList;
  }

  LineResult generatePath(List<Offset> ol, List<Offset> bottomLine, isBottom, LineGroupData group, int index) {
    Line line = Line(ol);
    StepType? type = series.stepLineFun?.call(group);
    if (type != null) {
      if (type == StepType.step) {
        line = Line(line.step());
      } else if (type == StepType.after) {
        line = Line(line.stepAfter());
      } else {
        line = Line(line.stepBefore());
      }
      Path path = Area(line.pointList, bottomLine, upSmooth: false, downSmooth: false).toPath(true);
      return LineResult(group, line.pointList, line.toPath(false), path);
    }
    LineStyle? lineStyle = getLineStyle(group, index);
    bool smooth = lineStyle?.smooth ?? false;
    Path path = Area(ol, bottomLine, upSmooth: smooth, downSmooth: isBottom ? false : smooth).toPath(true);
    line = Line(ol, smooth: smooth);
    return LineResult(group, ol, line.toPath(false), path);
  }

  @override
  AreaStyle? generateAreaStyle(SingleNode<LineItemData, LineGroupData> node) {
    var s = getAreaStyle(node.data.parent, node.data.groupIndex);
    if (s == null || series.areaStyleFun != null) {
      return s;
    }
    return s.convert(node.status);
  }

  @override
  LineStyle? generateLineStyle(SingleNode<LineItemData, LineGroupData> node) {
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
  final LineGroupData data;
  final List<Offset> offsetList;
  final Path borderPath;
  final Path areaPath;

  AreaStyle? areaStyle;
  LineStyle? lineStyle;

  LineResult(this.data, this.offsetList, this.borderPath, this.areaPath);
}
