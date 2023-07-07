import 'package:flutter/material.dart';

import '../../functions.dart';
import '../../model/dynamic_text.dart';
import '../../model/text_position.dart';
import '../../style/label.dart';
import '../../style/line_style.dart';
import '../../symbol/chart_symbol.dart';
import 'mark_type.dart';

class MarkLine {
  ChartSymbol? startSymbol;
  ChartSymbol? endSymbol;
  bool touch;
  Fun2<int, LabelStyle>? labelStyle;
  LineStyle lineStyle;
  int precision; //精度
  MarkType startMarkType;

  // 如果endMakeType 为null 那么绘制时则是一条水平直线
  final MarkType? endMarkType;

  MarkLine({
    this.startSymbol,
    this.endSymbol,
    this.touch = false,
    this.labelStyle,
    this.lineStyle = const LineStyle(),
    this.precision = 2,
    this.startMarkType = MarkType.average,
    this.endMarkType,
  });

  void draw(Canvas canvas, Paint paint, Offset start, Offset end, {DynamicText? startText, DynamicText? endText}) {
    lineStyle.drawPolygon(canvas, paint, [start, end], false);
    startSymbol?.draw(canvas, paint, SymbolDesc(center: start));
    endSymbol?.draw(canvas, paint,  SymbolDesc(center: end));
    if (startText != null && startText.isNotEmpty) {
      TextDrawConfig config = TextDrawConfig(start);
      labelStyle?.call(0).draw(canvas, paint, startText, config);
    }
    if (endText != null && endText.isNotEmpty) {
      TextDrawConfig config = TextDrawConfig(end);
      labelStyle?.call(1).draw(canvas, paint, endText, config);
    }
  }
}
