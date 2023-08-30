import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class SymbolNode<T> extends DataNode<Offset, ChartSymbol> {
  T? originData;
  ChartSymbol? symbol;

  SymbolNode(this.symbol, int dataIndex, int groupIndex)
      : super(EmptySymbol(), dataIndex, groupIndex, Offset.zero, AreaStyle.empty, LineStyle.empty, LabelStyle.empty);

  @override
  void onDraw(Canvas canvas, Paint paint) {
    symbol?.draw(canvas, paint, attr);
  }

  @override
  ChartSymbol get data => throw ChartError(" you should use originData");

  @override
  bool contains(Offset offset) {
    var s = symbol;
    if (s == null) {
      return false;
    }
    return s.internal2(attr, s.size, offset);
  }


}
