import 'package:e_chart/e_chart.dart';
import 'pie_helper.dart';

/// 饼图
class PieView extends SeriesView<PieSeries, PieHelper> {
  PieView(super.context, super.series);

  @override
  void onDraw(CCanvas canvas) {
    List<PieData> nodeList = layoutHelper.dataSet;
    each(nodeList, (node, i) {
      node.onDraw(canvas, mPaint);
    });
  }

  @override
  PieHelper buildLayoutHelper(var oldHelper) {
    if (oldHelper != null) {
      oldHelper.context = context;
      oldHelper.view = this;
      oldHelper.series = series;
      return oldHelper;
    }
    return PieHelper(context, this, series);
  }
}
