import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class AxisLine extends ChartNotifier2 {
  bool show;
  double width;
  Color? color;
  List<num> dash;
  List<BoxShadow> shadow;
  AxisSymbol symbol; //控制是否显示箭头
  Size symbolSize;
  Offset symbolOffset;

  AxisLine({
    this.width = 1,
    this.dash = const [],
    this.shadow = const [],
    this.show = true,
    this.symbol = AxisSymbol.none,
    this.symbolSize = const Size.square(16),
    this.symbolOffset = Offset.zero,
    Color? color,
  }) {
    if (color != null) {
      this.color = color;
    }
  }

  LineStyle getStyle(AxisTheme theme) {
    if (!show) {
      return LineStyle.empty;
    }
    Color? color;
    if (this.color != null) {
      color = this.color;
    } else {
      color = theme.getAxisLineColor(0);
    }

    if (color == null) {
      return LineStyle.empty;
    }
    return LineStyle(color: color, dash: dash, shadow: shadow, smooth: 0);
  }

  double getLength() {
    if (!show) {
      return 0;
    }
    if (width <= 0) {
      return 0;
    }
    return width.toDouble();
  }
}
