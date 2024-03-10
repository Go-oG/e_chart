import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PointData extends RenderData2<Offset, ChartSymbol> {
  dynamic domain;
  dynamic value;

  int domainAxis;
  int valueAxis;

  PointData(
    this.domain,
    this.value, {
    this.domainAxis = 0,
    this.valueAxis = 0,
    super.id,
    super.name,
  }) {
    symbol = EmptySymbol.empty;
  }

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
  DataAttr toAttr() {
    return DataAttr(attr, drawIndex, label, labelLine, itemStyle, borderStyle, symbol.scale);
  }

  double get left => attr.dx - symbol.size.width / 2;

  double get top => attr.dy - symbol.size.height / 2;

  double get right => attr.dx + symbol.size.width / 2;

  double get bottom => attr.dy + symbol.size.height / 2;

  @override
  Offset initAttr() => Offset.zero;
}
