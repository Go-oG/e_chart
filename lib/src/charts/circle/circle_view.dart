import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/circle/circle_helper.dart';

class CircleView extends SeriesView<CircleSeries, CircleHelper> {
  CircleView(super.series);

  @override
  CircleHelper buildLayoutHelper() {
    return CircleHelper(context, series);
  }

  @override
  void onDraw(Canvas canvas) {
    each(layoutHelper.nodeList, (p0, p1) {
      p0.onDraw(canvas, mPaint);
    });
  }
}
