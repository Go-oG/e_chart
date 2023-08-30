import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class HexbinView extends SeriesView<HexbinSeries, HexbinLayout> {
  HexbinView(super.series);

  @override
  void onDraw(Canvas canvas) {
    for (var node in layoutHelper.nodeList) {
      node.onDraw(canvas, mPaint);
    }
  }

  @override
  HexbinLayout buildLayoutHelper() {
    series.layout.context = context;
    series.layout.series = series;
    return series.layout;
  }
}
