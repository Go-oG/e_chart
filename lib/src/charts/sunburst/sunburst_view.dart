import 'package:e_chart/e_chart.dart';
import 'sunburst_helper.dart';

/// 旭日图
class SunburstView extends SeriesView<SunburstSeries, SunburstHelper> {
  SunburstView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    var showNode = layoutHelper.showRootNode;
    showNode?.each((node, index, startNode) {
      node.onDraw(canvas, mPaint);
      return false;
    });
  }

  @override
  SunburstHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.clearRef();
    return SunburstHelper(context,this, series);
  }
}
