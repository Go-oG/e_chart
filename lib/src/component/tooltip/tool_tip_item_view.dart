import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class ToolTipItemView extends GestureView {
  MenuItem item;
  final LabelStyle _defaultSubStyle = const LabelStyle(textStyle: TextStyle(color: Colors.black87, fontSize: 13));

  late TextDraw _label;
  TextDraw? _subLabel;

  ToolTipItemView(super.context, this.item) {
    _label = TextDraw(item.title, item.titleStyle, Offset.zero, align: Alignment.centerLeft);
    if (item.desc != null) {
      _subLabel = TextDraw(item.desc!, item.descStyle ?? _defaultSubStyle, Offset.zero, align: Alignment.centerRight);
    }
  }

  @override
  Size onMeasure(MeasureSpec widthSpec, MeasureSpec heightSpec) {
    double parentWidth = widthSpec.size;
    double parentHeight = heightSpec.size;

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

    w += layoutParams.hPadding;
    h += layoutParams.vPadding;
    return Size(w.toDouble(), h.toDouble());
  }

  @override
  void onLayout(bool changed, double left, double top, double right, double bottom) {
    super.onLayout(changed, left, top, right, bottom);
    double c = layoutParams.topPadding + height / 2;
    double lf = layoutParams.leftPadding;
    if (item.symbol != null) {
      Size s = item.symbol!.size;
      lf += s.width + 8;
    }
    _label.updatePainter(offset: Offset(lf, c));
    _subLabel?.updatePainter(offset: Offset(width, c));
  }

  @override
  void onDraw(CCanvas canvas) {
    double c = layoutParams.topPadding + height / 2;
    if (item.symbol != null) {
      Size s = item.symbol!.size;
      item.symbol?.draw(canvas, mPaint, Offset(layoutParams.leftPadding + s.width / 2, c));
    }
    _label.draw(canvas, mPaint);
    _subLabel?.draw(canvas, mPaint);
  }

  @override
  void onDispose() {
    item = MenuItem.empty;
    _label = TextDraw.empty;
    _subLabel = TextDraw.empty;
    super.onDispose();
  }
}
