import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class HexbinNode extends DataNode2<HexAttr, ItemData, PositiveSymbol> {
  HexbinNode(
    super.symbol,
    super.data,
    super.dataIndex,
    super.groupIndex,
    super.attr,
    super.labelStyle,
  );

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    symbol.draw(canvas, paint, attr.center);

    var s = data.name;
    if (s == null || s.isEmpty) {
      return;
    }
    var ls = labelStyle;
    if (ls.show) {
      TextDrawInfo config = TextDrawInfo(attr.center, textAlign: TextAlign.center);
      ls.draw(canvas, paint, s, config);
    }
  }

  @override
  bool contains(Offset offset) {
    return symbol.contains(attr.center, offset);
  }

  @override
  void updateStyle(Context context, HexbinSeries series) {
    itemStyle = series.getItemStyle(context, data, dataIndex, status)??AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, data, dataIndex, status)??LineStyle.empty;
    labelStyle = series.getLabelStyle(context, data, dataIndex, status) ?? LabelStyle.empty;
    symbol.itemStyle=itemStyle;
    symbol.borderStyle=borderStyle;
  }
}

class HexAttr extends SymbolAttr {
  static final HexAttr zero = HexAttr.all(Hex(0, 0, 0), Offset.zero);
  final Hex hex;
  late Offset center;

  HexAttr(this.hex);

  HexAttr.all(this.hex, this.center);
}
