import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/boxplot/boxplot_helper.dart';

/// 单个盒须图
class BoxPlotView extends SeriesView<BoxplotSeries, BoxplotHelper> with GridChild {
  BoxPlotView(super.series);

  @override
  void onUpdateDataCommand(covariant Command c) {
    layoutHelper.doLayout(series.data, selfBoxBound, LayoutType.update);
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    layoutHelper.doLayout(series.data, selfBoxBound, LayoutType.layout);
  }

  @override
  void onDraw(Canvas canvas) {
    var of = context.findGridCoord().getTranslation();
    canvas.save();
    canvas.translate(of.dx, of.dy);

    layoutHelper.nodeMap.forEach((key, node) {
      if (node.data == null) {
        return;
      }
      var data = node.data!;
      var group = node.parent;
      var as = layoutHelper.buildAreaStyle(data, group, node.groupIndex, node.status);
      var ls = layoutHelper.buildLineStyle(data, group, node.groupIndex, node.status);
      node.areaStyle = as;
      node.lineStyle = ls;
      if (as == null && ls == null) {
        return;
      }
      Path area = node.extGet("areaPath");
      as?.drawPath(canvas, mPaint, area);
      Path p = node.extGet("path");
      ls?.drawPath(canvas, mPaint, p);
    });
    canvas.restore();
  }

  @override
  int getAxisDataCount(int axisIndex, bool isXAxis) {
    return series.data.length;
  }

  @override
  List<DynamicData> getAxisExtreme(int axisIndex, bool isXAxis) {
    return layoutHelper.getAxisExtreme(series, axisIndex, isXAxis);
  }

  @override
  BoxplotHelper buildLayoutHelper() {
    return BoxplotHelper(context, series);
  }
}
