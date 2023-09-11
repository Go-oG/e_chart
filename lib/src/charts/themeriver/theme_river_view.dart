import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'theme_river_helper.dart';

class ThemeRiverView extends SeriesView<ThemeRiverSeries, ThemeRiverHelper> {
  ThemeRiverView(super.series);

  @override
  void onDraw(Canvas canvas) {
    var nodeList = layoutHelper.nodeList;
    var tx = layoutHelper.translationX;
    var ty = layoutHelper.translationY;
    var ap = layoutHelper.animatorPercent;
    canvas.save();
    canvas.translate(tx, ty);
    canvas.clipRect(layoutHelper.getClipRect(series.direction,ap));
    for (var ele in nodeList) {
      ele.onDraw(canvas, mPaint);
    }
    canvas.restore();
  }

  @override
  ThemeRiverHelper buildLayoutHelper() {
    return ThemeRiverHelper(context, series);
  }
}
