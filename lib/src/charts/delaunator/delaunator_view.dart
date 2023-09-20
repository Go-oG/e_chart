import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

import 'delaunator_helper.dart';

class DelaunatorView extends SeriesView<DelaunatorSeries, DelaunatorHelper> {
  DelaunatorView(super.series);

  @override
  DelaunatorHelper buildLayoutHelper(DelaunatorHelper? oldHelper) {
    return DelaunatorHelper(context, this, series);
  }

  @override
  void onDraw(CCanvas canvas) {
    // AreaStyle style = AreaStyle(shader: SweepShader([Colors.deepPurple, Colors.blueAccent]));
    // style.drawRect(canvas, mPaint, selfBoxBound);
    var path = layoutHelper.path;
    LineStyle border = LineStyle(color: Colors.black, width: 1);
    border.drawPath(canvas, mPaint, path);
  }
}
