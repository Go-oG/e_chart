import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class RectSymbol extends ChartSymbol {
  final Size rectSize;
  final Corner corner;
  late final Rect rect;

  RectSymbol({
    this.rectSize = const Size(16, 16),
    this.corner = Corner.zero,
    super.borderStyle,
    super.itemStyle,
  }) {
    rect = Rect.fromCenter(center: Offset.zero, width: rectSize.width, height: rectSize.height);
  }

  @override
  Size get size => rectSize;

  @override
  bool contains(Offset center, Offset point) {
    return rect.contains2(point.translate(-center.dx, -center.dy));
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    if (!checkStyle()) {
      return;
    }
    itemStyle.drawRect(canvas, paint, rect, corner);
    borderStyle.drawRect(canvas, paint, rect, corner);
  }

  @override
  RectSymbol lerp(covariant RectSymbol end, double t) {
    Rect rect = Rect.lerp(this.rect, end.rect, t)!;
    return RectSymbol(
      rectSize: rect.size,
      corner: Corner.lerp(corner, end.corner, t),
      itemStyle: AreaStyle.lerp(itemStyle, end.itemStyle, t) ?? AreaStyle.empty,
      borderStyle: LineStyle.lerp(borderStyle, end.borderStyle, t) ?? LineStyle.empty,
    );
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    if (attr == null || attr.isEmpty) {
      return this;
    }
    if (attr.size == null && attr.corner == null) {
      return this;
    }
    return RectSymbol(
      rectSize: attr.size ?? rectSize,
      corner: attr.corner ?? corner,
      itemStyle: itemStyle,
      borderStyle: borderStyle,
    );
  }
}
