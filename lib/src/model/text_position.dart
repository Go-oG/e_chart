import 'dart:ui';

import 'package:e_chart/src/ext/text_style_ext.dart';
import 'package:flutter/material.dart';

import '../core/view_state.dart';

///文本绘制参数
class TextDrawConfig {
  final Offset offset;
  final Alignment align; //用于感知文本绘制位置
  final num maxWidth;
  final num minWidth;
  final num maxHeight;
  final num rotate; //文本相对于水平旋转的角度
  final num scaleFactor; //文本缩放参数
  final TextAlign textAlign;
  final TextDirection textDirection;
  final int? maxLines;
  final String? ellipsis;
  final bool ignoreOverText; //是否忽略绘制越界的文本

  TextDrawConfig(
    this.offset, {
    this.align = Alignment.center,
    this.scaleFactor = 1,
    this.maxWidth = double.maxFinite,
    this.minWidth = 0,
    this.rotate = 0,
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
    this.maxLines,
    this.maxHeight = double.maxFinite,
    this.ellipsis,
    this.ignoreOverText = false,
  });

  TextDrawConfig copyWith({
    Offset? offset,
    Alignment? align,
    double? scaleFactor,
    double? maxWidth,
    double? minWidth,
    double? rotate,
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines,
    double? maxHeight,
    String? ellipsis,
    bool? ignoreOverText,
  }) {
    return TextDrawConfig(
      offset ?? this.offset,
      align: align ?? this.align,
      scaleFactor: scaleFactor ?? this.scaleFactor,
      maxWidth: maxWidth ?? this.maxWidth,
      minWidth: minWidth ?? this.minWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      maxLines: maxLines ?? this.maxLines,
      rotate: rotate ?? this.rotate,
      textAlign: textAlign ?? this.textAlign,
      textDirection: textDirection ?? this.textDirection,
      ellipsis: ellipsis ?? this.ellipsis,
      ignoreOverText: ignoreOverText ?? this.ignoreOverText,
    );
  }

  ParagraphStyle toParagraphStyle({TextStyle? style}) {
    return ParagraphStyle(
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      fontSize: style?.fontSize,
      fontFamily: style?.fontFamily,
      fontWeight: style?.fontWeight,
      height: style?.height,
      ellipsis: ellipsis,
    );
  }

  TextPainter toPainter(String text, TextStyle textStyle, [Set<ViewState>? states]) {
    return textStyle.toPainter(text,
        ellipsis: ellipsis,
        maxLines: maxLines,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaleFactor: scaleFactor.toDouble(),
        states: states);
  }

  TextPainter toPainter2(TextSpan text) {
    return TextPainter(
        text: text,
        textAlign: textAlign,
        textDirection: textDirection,
        textScaleFactor: scaleFactor.toDouble(),
        maxLines: maxLines,
        ellipsis: ellipsis);
  }
}
