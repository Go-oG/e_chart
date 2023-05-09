import 'package:flutter/material.dart';

///文本绘制参数
class TextDrawConfig {
  final Offset offset;
  final Alignment align; //用于感知绘制文本位置
  final num maxWidth;
  final num minWidth;
  final num maxHeight;
  final num rotate; //文本相对于水平旋转的角度
  final num scaleFactor; //文本缩放参数
  final TextAlign textAlign;

  final TextDirection textDirection;
  final int? maxLines;
  final String? ellipsis;

  TextDrawConfig(
    this.offset, {
    this.align = Alignment.center,
    this.scaleFactor = 1,
    this.maxWidth = double.infinity,
    this.minWidth = 0,
    this.rotate = 0,
    this.textAlign = TextAlign.center,
    this.textDirection = TextDirection.ltr,
    this.maxLines,
    this.maxHeight=double.maxFinite,
    this.ellipsis,
  });
}
