import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../style/line_style.dart';
import '../theme.dart';
class BoxplotTheme {
  num borderWidth = 1;
  Color borderColor=Colors.black45;

  LineStyle? getBorderStyle() {
    if (borderWidth <= 0) {
      return null;
    }
    return LineStyle(color: borderColor, width: borderWidth);
  }
}

