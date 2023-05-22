import 'package:flutter/material.dart';

import '../../functions.dart';
import '../../model/text_position.dart';
import '../../style/label.dart';
import '../../style/line_style.dart';
import '../../style/symbol/symbol.dart';
import 'mark_type.dart';

class MarkLine {
  final ChartSymbol? startSymbol;
  final ChartSymbol? endSymbol;
  final bool touch;
  final StyleFun<int, LabelStyle>? labelStyle;
  final LineStyle lineStyle;
  final int precision; //精度
  final MarkType startMarkType;

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

  void draw(Canvas canvas, Paint paint, Offset start, Offset end, {String? startText, String? endText}) {
    lineStyle.drawPolygon(canvas, paint, [start, end], false);
    startSymbol?.draw(canvas, paint, start);
    endSymbol?.draw(canvas, paint, end);
    if (startText != null && startText.isNotEmpty) {
      TextDrawConfig config = TextDrawConfig(start);
      labelStyle?.call(0, null)?.draw(canvas, paint, startText, config);
    }
    if (endText != null && endText.isNotEmpty) {
      TextDrawConfig config = TextDrawConfig(end);
      labelStyle?.call(1, null)?.draw(canvas, paint, endText, config);
    }
  }
}
