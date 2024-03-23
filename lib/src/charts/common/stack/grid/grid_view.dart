import 'dart:math';

import 'package:e_chart/e_chart.dart';
import '../stack_view.dart';

abstract class GridView<T extends StackItemData, G extends StackGroupData<T, G>, S extends StackSeries<T, G>,
    L extends GridHelper<T, G, S>> extends StackView<T, G, S, L> {
  GridView(super.context, super.series);

  @override
  CoordInfo getEmbedCoord() {
    return CoordInfo(CoordType.grid, max(0, series.gridIndex));
  }

  @override
  void onDrawGroupBk(CCanvas canvas) {
    Set<ColumnNode> rectSet = {};
    each(layoutHelper.dataSet, (node, p1) {
      var column = node.parentNode;
      if (rectSet.contains(column)) {
        return;
      }
      var style = series.groupStyleFun?.call(node.parent);
      if (style != null) {
        if (series.coordType == CoordType.polar) {
          style.drawPath(canvas, mPaint, column.arc.toPath());
        } else {
          style.drawRect(canvas, mPaint, column.rect);
        }
      }
      rectSet.add(column);
    });
    return;
  }

  @override
  void onDrawBar(CCanvas canvas) {
    each(layoutHelper.dataSet, (node, p1) {
      if (node.dataIsNull) {
        return;
      }
      if (node.rect.isEmpty) {
        return;
      }
      node.onDraw(canvas, mPaint);
    });
  }

  @override
  void onDrawBarLabel(CCanvas canvas) {
    each(layoutHelper.dataSet, (node, p1) {
      if (node.rect.isEmpty) {
        return;
      }
      node.onDrawText(canvas, mPaint);
    });
  }

}
