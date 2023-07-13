import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/grid/base_grid_layout_helper.dart';
import '../grid/column_node.dart';
import '../grid/group_node.dart';

class LineLayoutHelper extends BaseGridLayoutHelper<LineItemData, LineGroupData, LineSeries> {
  List<LineResult> lineList = [];

  @override
  void onLayout(List<LineGroupData> data, LayoutAnimatorType type) {
    super.onLayout(data, type);

    Map<String, List<LineGroupData>> stackMap = {};
    List<LineGroupData> normalList = [];
    each(data, (group, i) {
      if (group.isStack) {
        List<LineGroupData> dl = stackMap[group.stackId!] ?? [];
        stackMap[group.stackId!] = dl;
        dl.add(group);
      } else {
        normalList.add(group);
      }
    });

    List<LineResult> lineList = [];

    List<Offset> bottomList = [Offset(0, height), Offset(width, height)];
    each(normalList, (group, i) {
      if (group.data.isEmpty) {
        return;
      }
      List<Offset> ol = [];
      each(group.data, (item, i) {
        var node = dataNodeMap[item]!;
        ol.add(node.position);
      });
      lineList.add(buildPath(ol, bottomList, true, group, i));
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
          var node = dataNodeMap[item]!;
          ol.add(node.position);
        });
        if (i == 0) {
          lineList.add(buildPath(ol, bottomList, true, group, i));
        } else {
          lineList.add(buildPath(ol, lineList[i - 1].offsetList, false, group, i));
        }
      });
    });

    this.lineList = lineList;
  }

  @override
  void onLayoutGroupNode(
    AxisGroup<LineItemData, LineGroupData> axisGroup,
    GroupNode<LineItemData, LineGroupData> groupNode,
    GridCoord coord,
    AxisIndex xIndex,
    DynamicData x,
  ) {
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
  void onLayoutColumnNode(ColumnNode<LineItemData, LineGroupData> columnNode, GridCoord coord, AxisIndex xIndex, DynamicData x) {
    super.onLayoutColumnNode(columnNode, coord, xIndex, x);
    GridAxis xAxis = coord.getAxis(xIndex.index, true);
    for (var node in columnNode.nodeList) {
      if (xAxis.category && !xAxis.categoryCenter) {
        node.position = node.rect.topLeft;
      } else {
        node.position = node.rect.topCenter;
      }
    }
  }

  LineResult buildPath(List<Offset> ol, List<Offset> bottomLine, isBottom, LineGroupData group, int index) {
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

    AreaStyle? style = series.styleFun?.call(group, index);
    bool smooth = false;
    if (style != null) {
      smooth = style.border?.smooth ?? false;
    } else {
      LineTheme theme = context.config.theme.lineTheme;
      smooth = theme.smooth;
    }
    Path path = Area(ol, bottomLine, upSmooth: smooth, downSmooth: isBottom ? false : smooth).toPath(true);
    line = Line(ol, smooth: smooth);
    return LineResult(group, ol, line.toPath(false), path);
  }
}

class LineResult {
  final LineGroupData data;
  final List<Offset> offsetList;
  final Path borderPath;
  final Path areaPath;

  LineResult(this.data, this.offsetList, this.borderPath, this.areaPath);
}
