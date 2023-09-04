import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/sunburst/sunburst_node.dart';
import 'package:flutter/material.dart';
import 'sunburst_helper.dart';

/// 旭日图
class SunburstView extends SeriesView<SunburstSeries, SunburstHelper> {
  SunburstView(super.series);

  @override
  void onDraw(Canvas canvas) {
    var showNode = layoutHelper.showRootNode;
    showNode?.each((node, index, startNode) {
      node.onDraw(canvas, mPaint);
      return false;
    });
  }

  @override
  SunburstHelper buildLayoutHelper() {
    return SunburstHelper(context, series);
  }
}
