import 'dart:ui';
import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/grid/base_grid_layout_helper.dart';
import '../grid/column_node.dart';
import '../grid/group_node.dart';

class LineLayoutHelper extends BaseGridLayoutHelper<LineItemData, LineGroupData, LineSeries> {
  List<Line> lineList = [];

  @override
  void onLayout(List<LineGroupData> data, LayoutAnimatorType type) {
    super.onLayout(data, type);
    List<Line> lineList = [];
    each(data, (group, p1) {
      if (group.data.isEmpty) {
        return;
      }
      List<Offset> ol = [];
      each(group.data, (item, i) {
        var node = dataNodeMap[item]!;
        ol.add(node.position);
      });
      lineList.add(Line(ol));
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
}
