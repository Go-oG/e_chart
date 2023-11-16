import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/boxplot/boxplot_helper.dart';

/// 单个盒须图
class BoxPlotView extends GridView<BoxplotData, BoxplotGroup, BoxplotSeries, BoxplotHelper> {
  BoxPlotView(super.series);

  @override
  void onDrawBar(CCanvas canvas) {
    var of = context.findGridCoord().translation;
    canvas.save();
    canvas.translate(of.dx, of.dy);
    each(layoutHelper.dataSet, (node, p1) {
      var data = node.data;
      if (data == null) {
        return;
      }

      if (node.itemStyle.notDraw && node.borderStyle.notDraw) {
        return;
      }
      Rect rect = layoutHelper.getAreaRect(node);
      List<List<Offset>> borderList = layoutHelper.getBorderList(node);
      node.itemStyle.drawRect(canvas, mPaint, rect);
      if (node.borderStyle.canDraw) {
        for (var list in borderList) {
          node.borderStyle.drawPolygon(canvas, mPaint, list);
        }
      }
    });

    canvas.restore();
  }

  @override
  BoxplotHelper buildLayoutHelper(BoxplotHelper? oldHelper) {
    oldHelper?.dispose();
    return BoxplotHelper(context, this, series);
  }
}
