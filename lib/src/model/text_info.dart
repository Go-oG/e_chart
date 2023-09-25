import 'dart:ui';
import 'package:flutter/material.dart';

import '../utils/index.dart';

///文本绘制参数
class TextDrawInfo {
  final Offset offset;
  final Alignment align; //用于感知文本绘制位置
  final num maxWidth;
  final num minWidth;
  final num maxHeight;
  final num rotate; //文本相对于水平旋转的角度
  final TextAlign textAlign;
  final TextDirection textDirection;
  final int? maxLines;
  final String? ellipsis;
  final bool ignoreOverText; //是否忽略绘制越界的文本
  num scaleFactor; //文本缩放参数

  TextDrawInfo(
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

  TextDrawInfo copyWith({
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
    return TextDrawInfo(
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

  final TextPainter _cachePainter = TextPainter();

  TextPainter toPainter2(TextSpan text) {
    fillPainter(_cachePainter);
    _cachePainter.text = text;
    return _cachePainter;
  }

  void fillPainter(TextPainter painter) {
    painter
      ..textAlign = textAlign
      ..textDirection = textDirection
      ..maxLines = maxLines
      ..ellipsis = ellipsis;
  }

  static TextDrawInfo fromRect(Rect rect, Alignment align, [bool inside = true]) {
    return fromAlign(rect.topLeft, rect.topRight, rect.bottomLeft, rect.bottomRight, align);
  }

  static TextDrawInfo fromAlign(Offset lt, Offset rt, Offset lb, Offset rb, Alignment align, [bool inside = true]) {
    Offset p0 = lt;
    Offset p1 = rt;
    Offset p2 = rb;
    Offset p3 = lb;
    double centerX = (p0.dx + p1.dx) / 2;
    double centerY = (p0.dy + p3.dy) / 2;
    double topW = (p1.dx - p0.dx).abs();
    double x = centerX + align.x * topW / 2;
    double y = centerY + align.y * (p1.dy - p2.dy).abs() / 2;
    Offset offset = Offset(x, y);
    Alignment textAlign = toInnerAlign(align);
    if (!inside) {
      textAlign = Alignment(-textAlign.x, -textAlign.y);
    }
    return TextDrawInfo(offset, align: textAlign);
  }
}
