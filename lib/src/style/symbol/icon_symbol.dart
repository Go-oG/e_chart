import 'dart:ui';
import 'package:e_chart/src/model/index.dart';
import 'package:flutter/material.dart';

import '../label.dart';
import 'symbol.dart';

class IconSymbol extends ChartSymbol {
  final Icon icon;
  late final LabelStyle style;

  IconSymbol(this.icon) {
    IconData data = icon.icon!;
    double? iconSize = icon.size ?? 8;
    double? iconFill = icon.fill;
    double? iconWeight = icon.weight;
    double? iconGrade = icon.grade;
    double? iconOpticalSize = icon.opticalSize;
    List<Shadow>? iconShadows = icon.shadows;
    TextStyle textStyle = TextStyle(
      fontVariations: <FontVariation>[
        if (iconFill != null) FontVariation('FILL', iconFill),
        if (iconWeight != null) FontVariation('wght', iconWeight),
        if (iconGrade != null) FontVariation('GRAD', iconGrade),
        if (iconOpticalSize != null) FontVariation('opsz', iconOpticalSize),
      ],
      inherit: false,
      color: icon.color,
      fontSize: iconSize,
      fontFamily: data.fontFamily,
      package: data.fontPackage,
      shadows: iconShadows,
    );
    style = LabelStyle(textStyle: textStyle, lineMargin: 0);
  }

  @override
  void draw(Canvas canvas, Paint paint, Offset center) {
    TextDrawConfig config = TextDrawConfig(center, align: Alignment.center);
    style.draw(canvas, paint, String.fromCharCode(icon.icon!.codePoint), config);
  }

  @override
  Size get size {
    double s = icon.size ?? 8;
    return Size.square(s);
  }
}
