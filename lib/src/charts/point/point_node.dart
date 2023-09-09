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
  ) : super(symbol, data, dataIndex, groupIndex, Offset.zero, LabelStyle.empty);

  @override
  bool contains(Offset offset) {
    return symbol.contains(attr, offset);
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    symbol.draw(canvas, paint, attr);
    var label = data.label;
    var labelConfig = this.labelConfig;
    if (label != null && label.isNotEmpty && labelConfig != null) {
      labelStyle.draw(canvas, paint, label, labelConfig);
    }
  }

  @override
  void updateStyle(Context context, covariant PointSeries series) {
    symbol = series.getSymbol(context, data, dataIndex, group,  status);
    itemStyle = symbol.itemStyle;
    borderStyle=symbol.borderStyle;
    borderStyle = symbol.borderStyle;
  }

  @override
  NodeAttr toAttr() {
    return NodeAttr(
      attr,
      drawIndex,
      label,
      labelConfig,
      labelLine,
      itemStyle,
      borderStyle,
      labelStyle,
      symbol.scale,
    );
  }
}