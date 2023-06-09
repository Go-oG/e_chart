import 'dart:ui';

import 'package:e_chart/src/style/symbol/pin_symbol.dart';

import '../../model/dynamic_text.dart';
import '../../model/text_position.dart';
import '../../style/label.dart';
import '../../style/symbol/symbol.dart';
import 'mark_type.dart';

class MarkPoint {
  ChartSymbol symbol = PinSymbol();
  bool touch;
  LabelStyle? labelStyle;
  MarkType markType;
  int precision; //精度

  MarkPoint({
    ChartSymbol? symbol,
    this.touch = false,
    this.labelStyle,
    this.markType = MarkType.average,
    this.precision = 1,
  }) {
    if (symbol != null) {
      this.symbol = symbol;
    }
  }

  void draw(Canvas canvas, Paint paint, Offset offset, [DynamicText? text]) {
    symbol.draw(canvas, paint, offset, 1);
    if (text != null && text.isNotEmpty) {
      labelStyle?.draw(canvas, paint, text, TextDrawConfig(offset));
    }
  }
}
