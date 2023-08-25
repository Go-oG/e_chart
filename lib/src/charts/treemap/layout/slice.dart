import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';


/// 从上到下
class SliceLayout extends TreemapLayout {
  @override
  void onLayout2(TreeMapNode root, LayoutType type) {
    layoutChildren(boxBound, root.children);
  }

  ///从上到下
  static void layoutChildren(Rect rect, List<TreeMapNode> nodeList) {
    double w = rect.width;
    double h = rect.height;
    double allValue = computeAllRatio(nodeList);
    double topOffset = rect.top;
    for (var node in nodeList) {
      double ratio = node.areaRatio / allValue;
      double h2 = ratio * h;
      node.setPosition(Rect.fromLTWH(rect.left, topOffset, w, h2));
      topOffset += node.getPosition().height;
    }
  }
}
