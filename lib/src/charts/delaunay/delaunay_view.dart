import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'delaunay_helper.dart';

class DelaunayView extends SeriesView<DelaunaySeries, DelaunayHelper> {
  DelaunayView(super.series);

  @override
  DelaunayHelper buildLayoutHelper(DelaunayHelper? oldHelper) {
    return DelaunayHelper(context, this, series);
  }

  @override
  void onDraw(CCanvas canvas) {
    canvas.save();
    canvas.translate(translationX, translationY);
    var list=layoutHelper.showNodeList;
    each(list, (p0, p1) {
      p0.onDraw(canvas, mPaint);
    });
    canvas.restore();
  }
  @override
  bool get enableDrag => true;
}
