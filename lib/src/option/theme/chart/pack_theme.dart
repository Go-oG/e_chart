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
    var s = color.withOpacity(color.opacity * 0.2);
    var e = color;
    var t = Color.lerp(s, e, deep / maxDeep);
    return AreaStyle(color: t);
  }

  LineStyle? getBorderStyle() {
    if (borderColor == null || borderWidth <= 0) {
      return null;
    }
    return LineStyle(color: borderColor!, width: borderWidth);
  }
}
