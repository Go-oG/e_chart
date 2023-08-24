import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class RectSymbol extends ChartSymbol {
  LineStyle? border;
  AreaStyle? style;
  Size rectSize;
  Corner corner;

  late Rect rect;

  RectSymbol({
    this.border,
    this.style,
    this.rectSize = const Size(16, 16),
    this.corner = Corner.zero,
  }) {
    if (style == null && border == null) {
      throw ChartError("style 和border不能同时为空");
    }
    rect = Rect.fromCenter(
      center: Offset.zero,
      width: rectSize.width,
      height: rectSize.height,
    );
  }

  @override
  Size get size => rectSize;

  @override
  bool internal(Offset point) {
    return rect.contains2(point.translate(-center.dx, -center.dy));
  }

  @override
  void draw2(Canvas canvas, Paint paint, Offset offset, Size size) {
    center = offset;
    if (size != rectSize) {
      rectSize = size;
      rect = Rect.fromCenter(
        center: Offset.zero,
        width: size.width,
        height: size.height,
      );
    }
    canvas.save();
    canvas.translate(center.dx, center.dy);
    style?.drawRect(canvas, paint, rect, corner);
    border?.drawRect(canvas, paint, rect, corner);
    canvas.restore();
  }

  @override
  bool internal2(Offset center, Size size, Offset point) {
    return Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    ).contains2(point);
  }
}
