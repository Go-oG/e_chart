import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/circle/circle_helper.dart';

class CircleView extends SeriesView<CircleSeries, CircleHelper> {
  CircleView(super.context,super.series);

  @override
  CircleHelper buildLayoutHelper(var oldHelper) {
    if (oldHelper != null) {
      oldHelper.view = this;
      oldHelper.series = series;
      oldHelper.context = context;
    }
    return CircleHelper(context, this, series);
  }

  @override
  void onDraw(CCanvas canvas) {
    each(layoutHelper.dataSet, (p0, p1) {
      p0.onDraw(canvas, mPaint);
    });
  }
}
