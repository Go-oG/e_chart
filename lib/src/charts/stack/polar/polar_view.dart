import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import '../stack_view.dart';

abstract class PolarView<T extends StackItemData, G extends StackGroupData<T>, S extends StackSeries<T, G>,
    L extends PolarHelper<T, G, S>> extends StackView<T, G, S, L> with PolarChild {
  PolarView(super.series);

  @override
  void onDrawGroupBk(CCanvas canvas) {
    Set<GroupNode> rectSet = {};
    AreaStyle s2 = AreaStyle(color: series.groupHoverColor);
    Offset offset = layoutHelper.getTranslation();
    canvas.save();
    canvas.translate(offset.dx, 0);
    var nodeMap = layoutHelper.showNodeMap;
    nodeMap.forEach((key, node) {
      var group = node.parentNode.parentNode;
      if (rectSet.contains(group)) {
        return;
      }
      AreaStyle? style;
      if (series.groupStyleFun != null) {
        style = series.groupStyleFun?.call(node.originData, node.parent, node.status);
      } else if (group.isHover) {
        style = s2;
      }
      style?.drawPath(canvas, mPaint, group.arc.toPath());
      rectSet.add(group);
    });
    canvas.restore();
    return;
  }

  @override
  void onDrawBar(CCanvas canvas) {
    Offset offset = layoutHelper.getTranslation();
    final map = layoutHelper.showNodeMap;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    map.forEach((key, node) {
      if (node.originData == null) {
        return;
      }
      if (node.attr.arc.isEmpty) {
        return;
      }
      node.onDraw(canvas, mPaint);
    });
    canvas.restore();
  }

  @override
  void onDrawBarLabel(CCanvas canvas) {
    Offset offset = layoutHelper.getTranslation();
    final map = layoutHelper.showNodeMap;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    map.forEach((key, node) {
      if (node.originData == null) {
        return;
      }
      if (node.attr.arc.isEmpty) {
        return;
      }
      var data = node.originData!;
      var group = node.parent;
      LabelStyle? style = node.labelStyle;
      var config = node.labelConfig;
      if (!style.show || config == null) {
        return;
      }
      DynamicText? text = series.formatData(context, data, group,node.status);
      if (text == null || text.isEmpty) {
        return;
      }

      // ChartAlign align =node. series.getLabelAlign(context, data, group);
      // TextDrawInfo drawInfo = align.convert(node.attr.rect, style, series.direction);
      style.draw(canvas, mPaint, text, config);
    });
    canvas.restore();
  }

  @override
  List<dynamic> getAngleExtreme() {
    return layoutHelper.getAxisExtreme(0, false);
  }

  @override
  List<dynamic> getRadiusExtreme() {
    return layoutHelper.getAxisExtreme(0, true);
  }
}
