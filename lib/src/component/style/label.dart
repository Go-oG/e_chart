import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class LabelStyle {
  static const LabelStyle empty = LabelStyle(show: false);
  final bool show;
  final double rotate;
  final TextStyle textStyle;
  final AreaStyle? decoration;
  final OverFlow overFlow;
  final String ellipsis;
  final double lineMargin;
  final GuideLine? guideLine;
  final double minAngle; //对应在扇形形状中小于好多时则不显示

  const LabelStyle({
    this.show = true,
    this.rotate = 0,
    this.textStyle = const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.normal),
    this.decoration,
    this.overFlow = OverFlow.cut,
    this.ellipsis = '',
    this.guideLine,
    this.lineMargin = 4,
    this.minAngle = 0,
  });

  Size measure(DynamicText text, {num maxWidth = double.infinity, int? maxLine}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    if (text.isString) {
      TextPainter painter = textStyle.toPainter(text.text as String, maxLines: maxLine);
      painter.layout(maxWidth: maxWidth.toDouble());
      return painter.size;
    }
    if (text.isTextSpan) {
      TextPainter painter = TextPainter(
          text: text.text as TextSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          textScaleFactor: 1,
          maxLines: maxLine,
          ellipsis: ellipsis);
      painter.layout(maxWidth: maxWidth.toDouble());
      return painter.size;
    }
    Paragraph p = text.text as Paragraph;
    ParagraphConstraints constraints = ParagraphConstraints(width: maxWidth.toDouble());
    p.layout(constraints);
    return Size(p.width, p.height);
  }

  //TODO 待实现
  LabelStyle convert(Set<ViewState>? set) {
    if (set == null || set.isEmpty) {
      return this;
    }
    return this;
  }
}
