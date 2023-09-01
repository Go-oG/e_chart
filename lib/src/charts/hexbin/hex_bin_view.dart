import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class HexbinView extends SeriesView<HexbinSeries, HexbinLayout> {
  HexbinView(super.series);

  @override
  bool get enableDrag => true;

  @override
  void onDraw(Canvas canvas) {
    debugDrawRect(canvas, selfBoxBound);
    canvas.save();
    canvas.translate(layoutHelper.dragX, layoutHelper.dragY);
    for (var node in layoutHelper.nodeList) {
      node.onDraw(canvas, mPaint);
    }
    canvas.restore();
  }

  @override
  HexbinLayout buildLayoutHelper() {
    series.layout.context = context;
    series.layout.series = series;
    return series.layout;
  }

}
