import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class ToolTipItemView extends GestureView {
  final MenuItem item;

  ToolTipItemView(this.item);

  Size? _subSize;
  final LabelStyle _defaultSubStyle = const LabelStyle(textStyle: TextStyle(color: Colors.black87, fontSize: 13));

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    Size symbolSize = item.symbol?.size ?? Size.zero;
    num w = symbolSize.width;
    num h = symbolSize.height;

    final maxWidth = (parentWidth.isFinite || parentWidth.isNaN) ? double.infinity : parentWidth;
    Size s = item.titleStyle.measure(item.title, maxWidth: maxWidth);
    w += s.width;
    h = max([h, s.height]);
    if (item.desc != null) {
      final maxWidth = (parentWidth.isFinite || parentWidth.isNaN) ? double.infinity : parentWidth;
      var style = item.descStyle ?? const LabelStyle();
      s = style.measure(item.desc!, maxWidth: maxWidth);
      w += s.width;
      h = max([h, s.height]);
    }
    if (item.symbol != null) {
      w += 8;
    }
    if (item.desc != null) {
      w += 16;
    }

    w += layoutParams.padding.horizontal;
    h += layoutParams.padding.vertical;
    return Size(w.toDouble(), h.toDouble());
  }

  @override
  void onDraw(Canvas canvas) {
    double c = layoutParams.padding.top + height / 2;
    double left = layoutParams.padding.left;
    if (item.symbol != null) {
      Size s = item.symbol!.size;
      item.symbol?.draw(canvas, mPaint, Offset(layoutParams.padding.left + s.width / 2, c));
      left += s.width + 8;
    }
    item.titleStyle.draw(canvas, mPaint, item.title, TextDrawInfo(Offset(left, c), align: Alignment.centerLeft));
    if (_subSize != null && item.desc != null) {
      (item.descStyle ?? _defaultSubStyle).draw(canvas, mPaint, item.desc!, TextDrawInfo(Offset(width, c), align: Alignment.centerRight));
    }
  }
}
