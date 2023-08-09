import 'package:e_chart/e_chart.dart';
import 'package:e_chart/e_chart.dart' as ec;
import 'package:e_chart/src/charts/candlestick/candlestick_helper.dart';
import 'package:flutter/material.dart';

/// 单个K线图
class CandleStickView extends ec.GridView<CandleStickData, CandleStickGroup, CandleStickSeries, CandlestickHelper> {
  CandleStickView(super.series);

  @override
  void onDrawBar(Canvas canvas) {
    GridCoord layout = layoutHelper.findGridCoord();
    Offset of = layout.getTranslation();
    canvas.save();
    canvas.translate(of.dx, of.dy);
    each(layoutHelper.showNodeMap.values, (node, index) {
      if (node.data == null) {
        return;
      }
      var as = series.getAreaStyle(context, node.data, node.parent, node.styleIndex);
      var ls = series.getLineStyle(context, node.data, node.parent, node.styleIndex);
      as?.drawRect(canvas, mPaint, layoutHelper.getAreaRect(node));
      if (ls != null) {
        for (var bl in layoutHelper.getBorderList(node)) {
          ls.drawPolygon(canvas, mPaint, bl);
        }
      }
    });
    canvas.restore();
  }

  @override
  CandlestickHelper buildLayoutHelper() {
    return CandlestickHelper(context, series);
  }

}
