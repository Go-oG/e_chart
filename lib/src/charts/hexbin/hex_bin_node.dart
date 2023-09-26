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
  ){
    label.text=data.name??DynamicText.empty;
  }

  var sw = Stopwatch();

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    symbol.draw(canvas, paint, attr.center);
    sw.start();
    label.draw(canvas, paint);
    sw.stop();
    debugPrint('文字绘制耗时:${sw.elapsedMicroseconds}ns');
    sw.reset();
  }

  @override
  bool contains(Offset offset) {
    return symbol.contains(attr.center, offset);
  }

  @override
  void updateStyle(Context context, HexbinSeries series) {
    itemStyle = series.getItemStyle(context, data, dataIndex, status) ?? AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, data, dataIndex, status) ?? LineStyle.empty;
    label.style = series.getLabelStyle(context, data, dataIndex, status) ?? LabelStyle.empty;
    symbol.itemStyle = itemStyle;
    symbol.borderStyle = borderStyle;
  }
}

class HexAttr extends SymbolAttr {
  static final HexAttr zero = HexAttr.all(Hex(0, 0, 0), Offset.zero);
  final Hex hex;
  late Offset center;

  HexAttr(this.hex);

  HexAttr.all(this.hex, this.center);
}
