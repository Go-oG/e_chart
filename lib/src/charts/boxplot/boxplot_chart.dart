import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/boxplot/boxplot_helper.dart';

/// 单个盒须图
class BoxPlotView extends GridView<BoxplotData, BoxplotGroup, BoxplotSeries, BoxplotHelper> {
  BoxPlotView(super.series);

  @override
  void onDrawBar(Canvas canvas) {
    var of = context.findGridCoord().getScroll();
    canvas.save();
    canvas.translate(of.dx, of.dy);
    layoutHelper.showNodeMap.forEach((key, node) {
      if (node.data == null) {
        return;
      }
      var data = node.data!;
      var group = node.parent;
      var as = layoutHelper.buildAreaStyle(data, group, node.styleIndex, node.status);
      var ls = layoutHelper.buildLineStyle(data, group, node.styleIndex, node.status);
      node.areaStyle = as;
      node.lineStyle = ls;
      if (as == null && ls == null) {
        return;
      }
      Rect rect = layoutHelper.getAreaRect(node);
      List<List<Offset>> borderList = layoutHelper.getBorderList(node);
      as?.drawRect(canvas, mPaint, rect);
      if (ls != null) {
        for (var list in borderList) {
          ls.drawPolygon(canvas, mPaint, list);
        }
      }
    });
    canvas.restore();
  }

  @override
  BoxplotHelper buildLayoutHelper() {
    return BoxplotHelper(context, series);
  }
}
