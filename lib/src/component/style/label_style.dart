import 'dart:ui' as ui;

import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

class LabelStyle {
  static const LabelStyle empty = LabelStyle(show: false);
  final bool show;
  final double rotate;
  final TextStyle textStyle;
  final int? maxLines;
  final AreaStyle? decoration;
  final OverFlow overFlow;
  final String ellipsis;
  final double lineMargin;
  final GuideLine? guideLine;
  final double minAngle; //对应在扇形形状中小于好多时则不显示

  const LabelStyle({
    this.show = true,
    this.rotate = 0,
    this.maxLines,
    this.textStyle = const TextStyle(color: Color(0xFFFFFFFF), fontSize: 13, fontWeight: FontWeight.normal),
    this.decoration,
    this.overFlow = OverFlow.notDraw,
    this.ellipsis = '',
    this.guideLine,
    this.lineMargin = 4,
    this.minAngle = 0,
  });

  LabelStyle copy({
    bool? show,
    double? rotate,
    TextStyle? textStyle,
    AreaStyle? decoration,
    OverFlow? overFlow,
    String? ellipsis,
    GuideLine? guideLine,
    double? lineMargin,
    double? minAngle,
    int? maxLines,
    TextTransborder? transborder,
  }) {
    return LabelStyle(
      show: show ?? this.show,
      rotate: rotate ?? this.rotate,
      textStyle: textStyle ?? this.textStyle,
      decoration: decoration ?? this.decoration,
      overFlow: overFlow ?? this.overFlow,
      ellipsis: ellipsis ?? this.ellipsis,
      guideLine: guideLine ?? this.guideLine,
      lineMargin: lineMargin ?? this.lineMargin,
      maxLines: maxLines ?? this.maxLines,
      minAngle: minAngle ?? this.minAngle,
    );
  }

  Size measure(DynamicText text, {num maxWidth = double.infinity}) {
    if (text.isEmpty) {
      return Size.zero;
    }
    if (text.isString) {
      var painter = textStyle.toPainter(text.text as String, maxLines: maxLines);
      painter.layout(maxWidth: maxWidth.toDouble());
      return painter.size;
    }
    if (text.isTextSpan) {
      var painter = TextPainter(
        text: text.text as TextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        textScaleFactor: 1,
        maxLines: maxLines,
        ellipsis: ellipsis,
      );
      painter.layout(maxWidth: maxWidth.toDouble());
      return painter.size;
    }
    ui.Paragraph p = text.text as ui.Paragraph;
    ui.ParagraphConstraints constraints = ui.ParagraphConstraints(width: maxWidth.toDouble());
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

///文本超出绘制范围后的处理方式
enum TextTransborder {
  ignore,
  clip,
  scale,
}
