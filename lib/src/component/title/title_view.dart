import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class TitleView extends ChartView {
  DynamicText title;
  LabelStyle style;

  TitleView(this.title, this.style);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    if (title.isEmpty) {
      return Size.zero;
    }
    Size size= title.getTextSize(style.textStyle);
    return size;
  }

  @override
  void onDraw(CCanvas canvas) {
    var option = TextDrawInfo(Offset.zero, align: Alignment.topLeft);
    style.draw(canvas, mPaint, title, option);
  }
}
