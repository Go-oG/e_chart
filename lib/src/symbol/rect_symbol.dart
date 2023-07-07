import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class RectSymbol extends ChartSymbol {
  AreaStyle style;
  Size rectSize;
  num corner;

  RectSymbol(
    this.style, {
    this.rectSize = const Size(16, 16),
    this.corner = 0,
    super.center,
  });

  @override
  void draw(Canvas canvas, Paint paint, SymbolDesc info) {
    if (info.center != null && center != info.center) {
      center = info.center!;
    }
    if (info.size != null) {
      rectSize = info.size!;
    }

    AreaStyle style = this.style;
    AreaStyle? s = info.toStyle();
    if (s != null) {
      style = s;
    }
    style.drawRect(
        canvas,
        paint,
        Rect.fromCenter(
          center: center,
          width: rectSize.width,
          height: rectSize.height,
        ),
        corner.toDouble());
  }

  @override
  Size get size => rectSize;

  @override
  bool internal(Offset point) {
    return Rect.fromCenter(center: center, width: rectSize.width, height: rectSize.height).contains(point);
  }
}
