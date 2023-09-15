import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/circle/circle_helper.dart';

class CircleView extends SeriesView<CircleSeries, CircleHelper> {
  CircleView(super.series);

  @override
  CircleHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.dispose();
    return CircleHelper(context, this, series);
  }

  @override
  void onDraw(CCanvas canvas) {
    each(layoutHelper.nodeList, (p0, p1) {
      p0.onDraw(canvas, mPaint);
    });
  }
}
