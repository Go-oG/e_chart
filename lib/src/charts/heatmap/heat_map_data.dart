import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class HeatMapData extends RenderData<Rect> {
  dynamic x;
  dynamic y;
  num value = 0;


  HeatMapData(
    this.x,
    this.y,
    this.value, {
    super.id,
    DynamicText? name,
  });

  Alignment labelAlign = Alignment.center;
  ChartSymbol symbol = EmptySymbol.empty;

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    symbol.draw(canvas, paint, attr.center);
    label.draw(canvas, paint);
  }

  @override
  bool contains(Offset offset) {
    return attr.contains2(offset);
  }

  @override
  void updateStyle(Context context, covariant HeatMapSeries series) {
    var symbol = series.getSymbol(context, this);
    if (symbol != null) {
      this.symbol = symbol;
      itemStyle = symbol.itemStyle;
      borderStyle = symbol.borderStyle;
    } else {
      itemStyle = series.getItemStyle(context, this);
      borderStyle = series.getBorderStyle(context, this);
      this.symbol = RectSymbol(borderStyle: borderStyle, itemStyle: itemStyle, rectSize: attr.size);
    }
    label.updatePainter(style: series.getLabelStyle(context, this));
  }

  @override
  void updateLabelPosition(Context context, covariant HeatMapSeries series) {
    label.updatePainter(offset: TextDraw.offsetByRect(attr, labelAlign), align: TextDraw.alignConvert(labelAlign));
  }

  @override
  String toString() {
    return '${super.toString()} $symbol';
  }

  @override
  Rect initAttr() =>Rect.zero;
}
