import 'package:e_chart/e_chart.dart';

import 'funnel_helper.dart';

/// 漏斗图
class FunnelView extends SeriesView<FunnelSeries, FunnelHelper> {
  FunnelView(super.context, super.series);

  @override
  void onDraw(CCanvas canvas) {
    List<FunnelData> nodeList = layoutHelper.dataSet;
    if (nodeList.isEmpty) {
      return;
    }
    for (var node in nodeList) {
      node.onDraw(canvas, mPaint);
    }
  }

  @override
  FunnelHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.clearRef();
    if (oldHelper != null) {
      oldHelper.context = context;
      oldHelper.view = this;
      oldHelper.series = series;
      return oldHelper;
    }
    return FunnelHelper(context, this, series);
  }
}
