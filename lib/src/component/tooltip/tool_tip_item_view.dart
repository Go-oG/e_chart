import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class ToolTipItemView extends GestureView {
  MenuItem item;
  final LabelStyle _defaultSubStyle = const LabelStyle(textStyle: TextStyle(color: Colors.black87, fontSize: 13));

  late TextDraw _label;
  TextDraw? _subLabel;

  ToolTipItemView(this.item) {
    _label = TextDraw(item.title, item.titleStyle, Offset.zero, align: Alignment.centerLeft);
    if (item.desc != null) {
      _subLabel = TextDraw(item.desc!, item.descStyle ?? _defaultSubStyle, Offset.zero, align: Alignment.centerRight);
    }
  }

  @override
  Size onMeasure(double parentWidth, double parentHeight) {
    padding.left = layoutParams.leftPadding.convert(parentWidth);
    padding.top = layoutParams.topPadding.convert(parentHeight);
    padding.right = layoutParams.rightPadding.convert(parentWidth);
    padding.bottom = layoutParams.bottomPadding.convert(parentHeight);

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

    w += padding.horizontal;
    h += padding.vertical;
    return Size(w.toDouble(), h.toDouble());
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    double c = padding.top + height / 2;
    double lf = padding.left;
    if (item.symbol != null) {
      Size s = item.symbol!.size;
      lf += s.width + 8;
    }
    _label.updatePainter(offset: Offset(lf, c));
    _subLabel?.updatePainter(offset: Offset(width, c));
  }

  @override
  void onDraw(CCanvas canvas) {
    double c = padding.top + height / 2;
    if (item.symbol != null) {
      Size s = item.symbol!.size;
      item.symbol?.draw(canvas, mPaint, Offset(padding.left + s.width / 2, c));
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
