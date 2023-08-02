import 'package:chart_xutil/chart_xutil.dart';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class LegendViewGroup extends FlexLayout {
  final Legend legend;

  LegendViewGroup(this.legend) : super(align: Align2.center, direction: legend.direction) {
    _init();
  }

  void _init() {
    for (var item in legend.itemList) {
      addView(LegendItemView(item));
    }
  }
}

class LegendItemView extends ChartView {
  final LegendItem item;

  LegendItemView(this.item);

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    num w = item.symbol.size.width;
    num h = item.symbol.size.height;
    Size textSize = item.textStyle.measure(item.name, maxLine: 1);
    Position p = item.position;
    if (p == Position.left || p == Position.right) {
      w += textSize.width + item.gap;
      h = max([h, textSize.height]);
    } else if (p == Position.top || p == Position.bottom) {
      h += textSize.height + item.gap;
      w = max([w, textSize.width]);
    } else {
      w = max([w, textSize.width]);
      h = max([h, textSize.height]);
    }
    return Size(w.toDouble(), h.toDouble());
  }

  @override
  void onDraw(Canvas canvas) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, width, height));
    Position p = item.position;
    Size symbolSize = item.symbol.size;
    LabelStyle textStyle = item.textStyle;
    if (p == Position.left) {
      Offset o = Offset(0, height / 2);
      Size s = item.textStyle.draw(canvas, mPaint, item.name, TextDrawInfo(o, align: Alignment.centerLeft));
      o = Offset(s.width + item.gap + symbolSize.width / 2, height / 2);
      item.symbol.draw(canvas, mPaint, o);
    } else if (p == Position.right) {
      item.symbol.draw(canvas, mPaint, Offset(symbolSize.width / 2, height / 2));
      Offset o = Offset(symbolSize.width + item.gap, height / 2);
      textStyle.draw(canvas, mPaint, item.name, TextDrawInfo(o, align: Alignment.centerLeft));
    } else if (p == Position.top) {
      Offset o = Offset(width / 2, 0);
      Size s = textStyle.draw(canvas, mPaint, item.name, TextDrawInfo(o, align: Alignment.topCenter));
      o = Offset(width / 2, s.height + item.gap + symbolSize.height / 2);
      item.symbol.draw(canvas, mPaint, o);
    } else if (p == Position.bottom) {
      item.symbol.draw(canvas, mPaint, Offset(width / 2, height - symbolSize.height / 2));
      Offset o = Offset(width / 2, height - symbolSize.height);
      textStyle.draw(canvas, mPaint, item.name, TextDrawInfo(o, align: Alignment.bottomCenter));
    } else {
      Offset o = Offset(width / 2, height / 2);
      item.symbol.draw(canvas, mPaint, o);
      textStyle.draw(canvas, mPaint, item.name, TextDrawInfo(o, align: Alignment.center));
    }
    canvas.restore();
  }
}
