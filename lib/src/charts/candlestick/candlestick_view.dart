import 'package:e_chart/e_chart.dart';
import 'package:e_chart/e_chart.dart' as ec;
import 'package:e_chart/src/charts/candlestick/candlestick_helper.dart';
import 'package:flutter/material.dart';

/// 单个K线图
class CandleStickView extends ec.GridView<CandleStickData, CandleStickGroup, CandleStickSeries, CandlestickHelper> {
  CandleStickView(super.context, super.series);

  @override
  void onDrawBar(CCanvas canvas) {
    GridCoord layout = layoutHelper.findGridCoord();
    Offset of = Offset(scrollX, scrollY);
    var maxDx = layout.getMaxScroll().dx.abs();
    canvas.save();
    double w = of.dx.abs() > 0 ? (maxDx.abs() > 0 ? width + 10 : width) : width;
    canvas.clipRect(Rect.fromLTWH(of.dx.abs() == 0 ? -10 : 0, 0, w, height));
    each(layoutHelper.dataSet, (node, index) {
      var data = node.dataNull;
      if (data == null) {
        return;
      }
      var as = series.getAreaStyle(context, node, node.parent);
      var ls = series.getLineStyle(context, node, node.parent);
      if (ls.notDraw) {
        Logger.w("Candlestick LineStyle must not null");
        return;
      }
      double xo = -ls.width / 2.toDouble();
      canvas.save();
      canvas.translate(xo, 0);
      as.drawRect(canvas, mPaint, layoutHelper.getAreaRect(node));
      for (var bl in layoutHelper.getBorderList(node)) {
        ls.drawPolygon(canvas, mPaint, bl);
      }
      canvas.restore();
    });
    canvas.restore();
  }

  @override
  CandlestickHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.dispose();
    return CandlestickHelper(context, this, series);
  }
}
