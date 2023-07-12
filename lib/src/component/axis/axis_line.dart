import 'package:flutter/material.dart';

import '../../functions.dart';
import '../../model/theme_data.dart';
import '../../style/line_style.dart';
import 'axis_symbol.dart';

class AxisLine {
  bool show;
  LineStyle? lineStyle;

  AxisSymbol symbol; //控制是否显示箭头
  Size symbolSize;
  Offset symbolOffset;

  Fun3<int, int, LineStyle?>? styleFun;

  AxisLine({
    this.show = true,
    this.symbol = AxisSymbol.none,
    this.symbolSize = const Size.square(16),
    this.symbolOffset = Offset.zero,
    LineStyle? lineStyle,
    this.styleFun,
  }) {
    if (lineStyle != null) {
      this.lineStyle = lineStyle;
    }
  }

  LineStyle? getAxisLineStyle(int index, int maxIndex, AxisTheme theme) {
    if (!show) {
      return null;
    }
    LineStyle? style;
    if (styleFun != null) {
      style = styleFun?.call(index, maxIndex);
    } else {
      if (lineStyle != null) {
        style = lineStyle;
      } else {
        style = theme.getAxisLineStyle(index);
      }
    }
    return style;
  }
}
