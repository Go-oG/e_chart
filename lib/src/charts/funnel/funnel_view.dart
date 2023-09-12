import 'package:e_chart/e_chart.dart';

import 'funnel_node.dart';
import 'funnel_helper.dart';

/// 漏斗图
class FunnelView extends SeriesView<FunnelSeries, FunnelHelper> {
  FunnelView(super.series);

  @override
  void onDraw(CCanvas canvas) {
    List<FunnelNode> nodeList = layoutHelper.nodeList;
    if (nodeList.isEmpty) {
      return;
    }
    for (var node in nodeList) {
      node.onDraw(canvas, mPaint);
    }
  }

  @override
  FunnelHelper buildLayoutHelper() {
    return FunnelHelper(context, series);
  }
}
