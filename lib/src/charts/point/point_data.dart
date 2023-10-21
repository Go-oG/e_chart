import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PointData extends RenderData2<Offset, ChartSymbol> {
  dynamic x;
  dynamic y;
  dynamic value;

  int xAxisIndex;
  int yAxisIndex;

  PointData(
    this.x,
    this.y,
    this.value, {
    this.xAxisIndex = 0,
    this.yAxisIndex = 0,
  }) : super.attr(EmptySymbol.empty, Offset.zero);

  @override
  bool contains(Offset offset) {
    return symbol.contains(attr, offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    symbol.draw(canvas, paint, attr);
    label.draw(canvas, paint);
  }

  @override
  void updateStyle(Context context, covariant PointSeries series) {
    setSymbol(series.getSymbol(context, this), true);
  }

  @override
  NodeAttr toAttr() {
    return NodeAttr(attr, drawIndex, label, labelLine, itemStyle, borderStyle, symbol.scale);
  }

  double get left => attr.dx - symbol.size.width / 2;

  double get top => attr.dy - symbol.size.height / 2;

  double get right => attr.dx + symbol.size.width / 2;

  double get bottom => attr.dy + symbol.size.height / 2;
}
