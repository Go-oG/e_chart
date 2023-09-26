import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PointNode extends DataNode2<Offset, PointData, ChartSymbol> {
  final PointGroup group;

  PointNode(
    ChartSymbol symbol,
    this.group,
    PointData data,
    int dataIndex,
    int groupIndex,
  ) : super(symbol, data, dataIndex, groupIndex, Offset.zero, LabelStyle.empty) {
    label.text = data.name ?? DynamicText.empty;
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
    setSymbol(series.getSymbol(context, data, dataIndex, group, status), true);
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
