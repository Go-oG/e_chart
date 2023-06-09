import 'dart:ui';

import 'package:e_chart/src/style/symbol/pin_symbol.dart';

import '../../model/dynamic_text.dart';
import '../../model/text_position.dart';
import '../../style/label.dart';
import '../../style/symbol/symbol.dart';
import 'mark_type.dart';

class MarkPoint {
  final ChartSymbol symbol;
  final bool touch;
  final LabelStyle? labelStyle;
  final MarkType markType;
  final int precision; //精度

  MarkPoint({
    this.symbol = const PinSymbol(),
    this.touch = false,
    this.labelStyle,
    this.markType = MarkType.average,
    this.precision = 1,
  });

  void draw(Canvas canvas, Paint paint, Offset offset, [DynamicText? text]) {
    symbol.draw(canvas,  paint,offset);
    if (text != null && text.isNotEmpty) {
      labelStyle?.draw(canvas, paint, text, TextDrawConfig(offset));
    }
  }
}
