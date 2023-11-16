import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class TitleView extends ChartView {
  DynamicText title;
  LabelStyle style;

  late TextDraw label;

  TitleView(this.title, this.style) {
    label = TextDraw(title, style, Offset.zero, align: Alignment.topLeft);
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    if (title.isEmpty) {
      return Size.zero;
    }
    Size size = title.getTextSize(style.textStyle);
    return size;
  }

  @override
  void onDraw(CCanvas canvas) {
    label.draw(canvas, mPaint);
  }

  @override
  void onDispose() {
    title = DynamicText.empty;
    style = LabelStyle.empty;
    label = TextDraw.empty;
    super.onDispose();
  }

}
