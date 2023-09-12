import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class HeatMapNode extends DataNode<Rect, HeatMapData> {
  HeatMapNode(
    HeatMapData data,
    int dataIndex,
  ) : super(data, dataIndex, -1, Rect.zero, AreaStyle.empty, LineStyle.empty, LabelStyle.empty);
  Alignment labelAlign = Alignment.center;
  ChartSymbol symbol = RectSymbol(rectSize: Size.zero);

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    symbol.draw(canvas, paint, attr.center);
    var label = data.label;
    if (label == null || label.isEmpty) {
      return;
    }
    labelStyle.draw(canvas, paint, label, TextDrawInfo.fromRect(attr, labelAlign));
  }

  @override
  bool contains(Offset offset) {
    return attr.contains2(offset);
  }

  @override
  void updateStyle(Context context, covariant HeatMapSeries series) {
    var symbol = series.getSymbol(context, data, dataIndex, attr.size, status);
    if (symbol != null) {
      this.symbol = symbol;
      itemStyle=symbol.itemStyle;
      borderStyle=symbol.borderStyle;
    } else {
      itemStyle = series.getAreaStyle(context, data, dataIndex, status) ?? AreaStyle.empty;
      borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
      this.symbol = RectSymbol(borderStyle: borderStyle, itemStyle: itemStyle, rectSize: attr.size);
    }
    labelStyle = series.getLabelStyle(context, data, status) ?? LabelStyle.empty;
  }

  @override
  void updateSymbolSize(Size size) {
    symbol = symbol.copyBySize(size);
  }

}
