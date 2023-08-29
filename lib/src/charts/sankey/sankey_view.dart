import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'sankey_helper.dart';

/// 桑基图
class SankeyView extends SeriesView<SankeySeries, SankeyHelper> {
  SankeyView(super.series);

  @override
  void onDraw(Canvas canvas) {
    _drawLink(canvas);
    for (var element in layoutHelper.nodes) {
      var style = layoutHelper.getAreaStyle(element);
      style?.drawRect(canvas, mPaint, element.rect);
    }
  }

  void _drawLink(Canvas canvas) {
    for (var link in layoutHelper.links) {
      var style = layoutHelper.getLinkStyle(link.source, link.target);
      style.drawPath(canvas, mPaint, link.area.toPath(true));
    }
  }

  @override
  SankeyHelper buildLayoutHelper() {
    return SankeyHelper(context, series);
  }
}
