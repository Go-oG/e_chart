import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/treemap/treemap_helper.dart';
import 'package:flutter/material.dart';

/// 矩形树图
class TreeMapView extends SeriesView<TreeMapSeries, TreeMapHelper> {
  TreeMapView(super.series);

  @override
  void onCreate() {
    super.onCreate();
    series.addListener(handleSeriesCommand);
  }

  void handleSeriesCommand() {
    Command c = series.value;
    if (c == TreeMapSeries.commandBack) {
      layoutHelper.back();
      return;
    }
  }

  @override
  void onDraw(CCanvas canvas) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, width, height));
    canvas.translate(translationX, translationY);
    for (var c in layoutHelper.dataSet) {
      c.onDraw(canvas, mPaint);
    }
    canvas.restore();
  }

  @override
  TreeMapHelper buildLayoutHelper(var oldHelper) {
    if (oldHelper != null) {
      oldHelper.view = this;
      oldHelper.context = context;
      oldHelper.series = series;
      return oldHelper;
    }
    return TreeMapHelper(context, this, series);
  }

  @override
  bool get enableDrag => series.enableDrag;
}
