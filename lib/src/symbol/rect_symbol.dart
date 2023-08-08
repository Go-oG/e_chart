import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class RectSymbol extends ChartSymbol {
  final LineStyle? border;
  final AreaStyle? style;
  final Size rectSize;
  final Corner corner;

  RectSymbol({
    this.border,
    this.style,
    this.rectSize = const Size(16, 16),
    this.corner = Corner.zero,
  }) {
    if (style == null && border == null) {
      throw ChartError("style 和border不能同时为空");
    }
  }

  @override
  void draw(Canvas canvas, Paint paint, Offset offset) {
    center = offset;
    Rect rect = Rect.fromCenter(
      center: center,
      width: rectSize.width,
      height: rectSize.height,
    );
    style?.drawRect(canvas, paint, rect, corner);
    border?.drawRect(canvas, paint, rect, corner);
  }

  @override
  Size get size => rectSize;

  @override
  bool internal(Offset point) {
    return Rect.fromCenter(center: center, width: rectSize.width, height: rectSize.height).contains(point);
  }
}
