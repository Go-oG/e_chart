import 'package:e_chart/e_chart.dart';
import 'theme_river_helper.dart';

class ThemeRiverView extends SeriesView<ThemeRiverSeries, ThemeRiverHelper> {
  ThemeRiverView(super.context, super.series);

  @override
  void onDraw(CCanvas canvas) {
    var nodeList = layoutHelper.dataSet;
    var ap = layoutHelper.animatorPercent;
    canvas.clipRect(layoutHelper.getClipRect(series.direction, ap));
    for (var ele in nodeList) {
      ele.onDraw(canvas, mPaint);
    }
  }

  @override
  ThemeRiverHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.clearRef();
    return ThemeRiverHelper(context, this, series);
  }
}
