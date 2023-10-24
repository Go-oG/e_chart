import 'dart:ui';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class IconSymbol extends ChartSymbol {
  Icon? _icon;

  Icon get icon => _icon!;

  late final LabelStyle style;

  late TextDraw _label;

  IconSymbol(this._icon) {
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
    _label = TextDraw(DynamicText(String.fromCharCode(icon.icon!.codePoint)), style, Offset.zero);
  }

  @override
  Size get size {
    double s = icon.size ?? 8;
    return Size.square(s);
  }

  @override
  bool contains(Offset center, Offset point) {
    Size s = size;
    return Rect.fromCenter(center: center, width: s.width, height: s.height).contains(point);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    _label.draw(canvas, paint);
  }

  @override
  ChartSymbol lerp(covariant ChartSymbol end, double t) {
    return end;
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    return this;
  }

  @override
  void dispose() {
    _icon = const Icon(null);
    style = LabelStyle.empty;
    _label.dispose();
    _label = TextDraw.empty;
    super.dispose();
  }
}
