import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class TreeMapNode extends TreeNode<TreeData, Rect, TreeMapNode> {
  TreeMapNode(
    super.parent,
    super.data,
    super.dataIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle, {
    super.deep,
    super.maxDeep,
    super.value,
  }) {
    setExpand(false, false);
  }

  ///计算面积比
  double get areaRatio {
    if (parent == null) {
      return 1;
    }
    return value / parent!.value;
  }

  @override
  set attr(Rect a) {
    super.attr = a;
    var center = a.center;
    x = center.dx;
    y = center.dy;
    size = a.size;
  }

  @override
  bool contains(Offset offset) {
    return attr.contains2(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    Rect rect = attr;
    itemStyle.drawRect(canvas, paint, rect);
    var label = data.name;
    var config = labelConfig;
    var ls = labelStyle;
    if (label == null || label.isNotEmpty || config == null || !ls.show) {
      return;
    }

    if (rect.height < (ls.textStyle.fontSize ?? 0)) {
      return;
    }
    if (rect.width < (ls.textStyle.fontSize ?? 0) * 2) {
      return;
    }
    ls.draw(canvas, paint, label, config);

    // Alignment align = series.alignFun?.call(node) ?? Alignment.topLeft;
    // double x = rect.center.dx + align.x * rect.width / 2;
    // double y = rect.center.dy + align.y * rect.height / 2;
    //
    // TextDrawInfo config = TextDrawInfo(
    //   Offset(x, y),
    //   maxWidth: rect.width * 0.8,
    //   maxHeight: rect.height * 0.8,
    //   align: toInnerAlign(align),
    //   textAlign: TextAlign.start,
    //   maxLines: 2,
    //   ignoreOverText: true,
    // );
  }

  @override
  void updateStyle(Context context, covariant ChartSeries series) {

  }

}

