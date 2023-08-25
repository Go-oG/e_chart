import 'package:flutter/material.dart';

import '../../../functions.dart';
import '../../style/index.dart';
import '../../theme/axis_theme.dart';
import 'axis_symbol.dart';

class AxisLine {
  bool show;
  double width;
  Color? color;
  List<num> dash;
  List<BoxShadow> shadow;

  AxisSymbol symbol; //控制是否显示箭头
  Size symbolSize;
  Offset symbolOffset;

  Fun3<int, int, Color?>? styleFun;

  AxisLine({
    this.width = 2,
    this.dash = const [],
    this.shadow = const [],
    this.show = true,
    this.symbol = AxisSymbol.none,
    this.symbolSize = const Size.square(16),
    this.symbolOffset = Offset.zero,
    Color? color,
    this.styleFun,
  }) {
    if (color != null) {
      this.color = color;
    }
  }

  LineStyle? getAxisLineStyle(int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return null;
    }
    Color? color;
    if (styleFun != null) {
      color = styleFun?.call(index, maxIndex);
    } else {
      if (this.color != null) {
        color = this.color;
      } else {
        color = theme.getAxisLineColor(index);
      }
    }
    if (color == null) {
      return null;
    }
    return LineStyle(color: color, dash: dash, shadow: shadow, smooth: false);
  }
}
