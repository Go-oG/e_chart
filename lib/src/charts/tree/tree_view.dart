import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'tree_helper.dart';

class TreeView extends SeriesView<TreeSeries, TreeHelper> {
  TreeView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    var list = layoutHelper.nodeList;
    canvas.save();
    canvas.translate(translationX, translationY);
    List<TreeRenderNode> leaves = layoutHelper.rootNode.leaves();
    List<TreeRenderNode> pres = [];
    while (leaves.isNotEmpty) {
      for (var node in leaves) {
        if (node.parent != null) {
          drawLine(canvas, node.parent!, node);
          pres.add(node.parent!);
        }
      }
      leaves = pres;
      pres = [];
    }
    each(list, (node, p1) {
      node.onDraw(canvas, mPaint);
    });
    canvas.restore();
  }

  void drawSymbol(CCanvas canvas, TreeRenderNode node) {}

  void drawLine(CCanvas canvas, TreeRenderNode parent, TreeRenderNode child) {
    Path? path = series.layout.onLayoutNodeLink(parent, child);
    if (path != null) {
      series.getLinkStyle(context, parent, child).drawPath(canvas, mPaint, path);
    }
  }

  @override
  TreeHelper buildLayoutHelper(var oldHelper) {
    if (oldHelper != null) {
      oldHelper.context = context;
      oldHelper.series = series;
      oldHelper.view = this;
      return oldHelper;
    }
    return TreeHelper(context, this, series);
  }

  @override
  bool get enableDrag => true;
}
