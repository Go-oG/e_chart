import 'dart:ui';
import '../../model/text_position.dart';
import '../../style/label.dart';
import '../../style/symbol_style.dart';
import 'mark_type.dart';

class MarkPoint {
  final SymbolStyle symbolStyle;
  final bool touch;
  final LabelStyle? labelStyle;
  final MarkType markType;
  final int precision; //精度

  MarkPoint({
    this.symbolStyle = const SymbolStyle(),
    this.touch = false,
    this.labelStyle,
    this.markType = MarkType.average,
    this.precision = 1,
  });

  void draw(Canvas canvas, Paint paint, Offset offset, [String? text]) {
    symbolStyle.draw(canvas,  paint,offset);
    if (text != null && text.isNotEmpty) {
      labelStyle?.draw(canvas, paint, text, TextDrawConfig(offset));
    }
  }
}
