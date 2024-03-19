import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import '../stack_view.dart';

abstract class PolarView<T extends StackItemData, G extends StackGroupData<T, G>, S extends StackSeries<T, G>,
    L extends PolarHelper<T, G, S>> extends StackView<T, G, S, L> with PolarChild {
  PolarView(super.context, super.series);

  @override
  void onDrawGroupBk(CCanvas canvas) {
    Set<GroupNode> rectSet = {};
    AreaStyle s2 = AreaStyle(color: series.groupHoverColor);
    each(layoutHelper.dataSet, (node, p1) {
      var group = node.parentNode.parentNode;
      if (rectSet.contains(group)) {
        return;
      }
      AreaStyle? style;
      if (series.groupStyleFun != null) {
        style = series.groupStyleFun?.call(node.parent);
      } else if (group.isHover) {
        style = s2;
      }
      style?.drawPath(canvas, mPaint, group.arc.toPath());
      rectSet.add(group);
    });
    return;
  }

  @override
  void onDrawBar(CCanvas canvas) {
    each(layoutHelper.dataSet, (node, p1) {
      if (node.data == null) {
        return;
      }
      if (node.arc.isEmpty) {
        return;
      }
      node.onDraw(canvas, mPaint);
    });
  }

  @override
  void onDrawBarLabel(CCanvas canvas) {
    each(layoutHelper.dataSet, (node, p1) {
      if (node.arc.isEmpty) {
        return;
      }
      node.onDrawText(canvas, mPaint);
    });
  }

  @override
  List getPolarExtreme(bool radius) {
    if (radius) {
      return layoutHelper.getAxisExtreme(0, true);
    }
    return layoutHelper.getAxisExtreme(0, false);
  }
}
