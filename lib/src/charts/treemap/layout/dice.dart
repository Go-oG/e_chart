import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

//从左至右
class DiceLayout extends HierarchyLayout<TreeMapData,TreeMapSeries> {

  @override
 void onLayout(TreeMapData data,var params) {
    if (data.notChild) {
      return ;
    }
    layoutChildren(params.boxBound, data.children);
  }

  static void layoutChildren(Rect area, List<TreeMapData> nodeList) {
    if (nodeList.isEmpty) {
      return;
    }
    double leftOffset = area.left;
    double w = area.width;
    double h = area.height;
    num allRatio = computeAllRatio(nodeList);
    for (var node in nodeList) {
      double p = node.areaRatio / allRatio;
      double w2 = w * p;
      Rect rect = Rect.fromLTWH(leftOffset, area.top, w2, h);
      node.attr=rect;
      leftOffset += rect.width;
    }
  }
}
