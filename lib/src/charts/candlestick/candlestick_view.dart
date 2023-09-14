import 'package:e_chart/e_chart.dart';
import 'package:e_chart/e_chart.dart' as ec;
import 'package:e_chart/src/charts/candlestick/candlestick_helper.dart';
import 'package:flutter/material.dart';

/// 单个K线图
class CandleStickView extends ec.GridView<CandleStickData, CandleStickGroup, CandleStickSeries, CandlestickHelper> {
  CandleStickView(super.series);

  @override
  void onDrawBar(CCanvas canvas) {
    GridCoord layout = layoutHelper.findGridCoord();
    Offset of = layout.translation;
    var maxDx = layout.getMaxScroll().dx.abs();
    canvas.save();
    double w = of.dx.abs() > 0 ? (maxDx.abs() > 0 ? width + 10 : width) : width;
    canvas.clipRect(Rect.fromLTWH(of.dx.abs() == 0 ? -10 : 0, 0, w, height));
    canvas.translate(of.dx, of.dy);
    each(layoutHelper.showNodeMap.values, (node, index) {
      var data=node.originData;
      if (data == null) {
        return;
      }
      var as = series.getAreaStyle(context, data, node.parent, node.styleIndex, node.status);
      var ls = series.getLineStyle(context, data, node.parent, node.styleIndex, node.status);
      if (ls == null) {
        throw ChartError("Candlestick LineStyle must not null");
      }
      double xo = -ls.width / 2.toDouble();
      canvas.save();
      canvas.translate(xo, 0);
      as?.drawRect(canvas, mPaint, layoutHelper.getAreaRect(node));
      for (var bl in layoutHelper.getBorderList(node)) {
        ls.drawPolygon(canvas, mPaint, bl);
      }
      canvas.restore();
    });
    canvas.restore();
  }

  @override
  CandlestickHelper buildLayoutHelper() {
    return CandlestickHelper(context, series);
  }

  @override
  bool? get clipSelf => false;
}
