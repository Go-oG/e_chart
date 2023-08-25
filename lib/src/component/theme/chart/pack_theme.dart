import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class PackTheme {
  Color color = Colors.blue;
  Color? borderColor;
  num borderWidth = 0;

  AreaStyle getAreaStyle(int deep, int maxDeep) {
    if (maxDeep <= deep || maxDeep <= 0) {
      return AreaStyle(color: color);
    }
    HSLColor hslColor = HSLColor.fromColor(color);
    double hue = hslColor.hue * (1 - (deep / maxDeep));
    return AreaStyle(color: hslColor.withHue(hue).toColor());
  }

  LineStyle? getBorderStyle() {
    if (borderColor == null || borderWidth <= 0) {
      return null;
    }
    return LineStyle(color: borderColor!, width: borderWidth);
  }
}
