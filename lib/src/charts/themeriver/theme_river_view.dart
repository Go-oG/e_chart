import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'theme_river_helper.dart';

class ThemeRiverView extends SeriesView<ThemeRiverSeries, ThemeRiverHelper> {

  ThemeRiverView(super.series);

  @override
  void onDraw(Canvas canvas) {
    var nodeList=layoutHelper.nodeList;
    canvas.save();
    var tx=layoutHelper.tx;
    var ty=layoutHelper.ty;
    var ap=layoutHelper.animatorPercent;
    canvas.translate(tx, ty);
    if (series.direction == Direction.horizontal) {
      canvas.clipRect(Rect.fromLTWH(tx.abs(), ty.abs(), width * ap, height));
    } else {
      canvas.clipRect(Rect.fromLTWH(tx.abs(), ty.abs(), width, height * ap));
    }
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
