import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class TreeMapNode extends TreeNode<TreeData, TreeMapAttr, TreeMapNode> {
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
  void setAttr(TreeMapAttr po) {
    super.setAttr(po);
    var center = po.rect.center;
    x = center.dx;
    y = center.dy;
    size = po.rect.size;
  }

  @override
  bool contains(Offset offset) {
    return attr.rect.contains2(offset);
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    Rect rect = attr.rect;
    itemStyle.drawRect(canvas, paint, rect);
    var label = data.label;
    var config = attr.textConfig;
    var ls = labelStyle;
    if (label == null || label.isNotEmpty || config == null ||  !ls.show) {
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
}

class TreeMapAttr {
  Rect rect = Rect.zero;
  TextDrawInfo? textConfig;

  TreeMapAttr(this.rect, this.textConfig);

  TreeMapAttr.of();
}
