import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class HexbinData extends RenderData2<HexAttr, PositiveSymbol> {
  HexbinData({
    super.id,
    super.name,
  }) : super.of() {
    attr = HexAttr.zero;
    symbol = PositiveSymbol(count: 6);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    symbol.draw(canvas, paint, attr.center);
    label.draw(canvas, paint);
  }

  @override
  bool contains(Offset offset) {
    return symbol.contains(attr.center, offset);
  }

  @override
  void updateStyle(Context context, HexbinSeries series) {
    itemStyle = series.getItemStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    label.style = series.getLabelStyle(context, this);
    symbol.itemStyle = itemStyle;
    symbol.borderStyle = borderStyle;
  }

  @override
  void updateLabelPosition(Context context, covariant ChartSeries series) {
    label.updatePainter(offset: attr.center, align: Alignment.center);
  }
}

class HexAttr extends SymbolAttr {
  static final HexAttr zero = HexAttr.all(Hex(0, 0, 0), Offset.zero);
  final Hex hex;
  Offset center = Offset.zero;

  HexAttr(this.hex);

  HexAttr.all(this.hex, this.center);
}
