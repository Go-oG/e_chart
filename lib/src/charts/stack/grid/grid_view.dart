import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import '../stack_view.dart';

abstract class GridView<T extends StackItemData, G extends StackGroupData<T>, S extends StackSeries<T, G>,
    L extends GridHelper<T, G, S>> extends StackView<T, G, S, L> with GridChild {
  GridView(super.series);

  @override
  void onDrawGroupBk(CCanvas canvas) {
    Set<ColumnNode> rectSet = {};
    Offset offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    each(layoutHelper.nodeList, (node, p1) {
      var column = node.parentNode;
      if (rectSet.contains(column)) {
        return;
      }
      var style = series.groupStyleFun?.call(node.originData, node.parent, node.status);
      if (style != null) {
        if (series.coordType == CoordType.polar) {
          style.drawPath(canvas, mPaint, column.arc.toPath());
        } else {
          style.drawRect(canvas, mPaint, column.rect);
        }
      }
      rectSet.add(column);
    });
    canvas.restore();
    return;
  }

  @override
  void onDrawBar(CCanvas canvas) {
    Offset offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    each(layoutHelper.nodeList, (node, p1) {
      if (node.originData == null) {
        return;
      }
      if (node.rect.isEmpty) {
        return;
      }
      node.onDraw(canvas, mPaint);
    });
    canvas.restore();
  }

  @override
  void onDrawBarLabel(CCanvas canvas) {
    canvas.save();
    Offset offset = layoutHelper.getTranslation();
    canvas.translate(offset.dx, offset.dy);
    each(layoutHelper.nodeList, (node, p1) {
      if (node.rect.isEmpty) {
        return;
      }
      node.onDrawText(canvas, mPaint);
    });
    canvas.restore();
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    int count = 0;
    for (var data in series.data) {
      if (data.data.length > count) {
        count = data.data.length;
      }
    }
    return count;
  }

  @override
  List<dynamic> getAxisExtreme(int axisIndex, bool isXAxis) {
    return layoutHelper.getAxisExtreme(axisIndex, isXAxis);
  }

  @override
  List getViewPortAxisExtreme(int axisIndex, bool isXAxis, BaseScale scale) {
    return layoutHelper.getViewPortAxisExtreme(axisIndex, isXAxis, scale);
  }
}
