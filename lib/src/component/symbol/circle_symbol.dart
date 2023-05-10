import 'dart:math';
import 'package:flutter/material.dart';
import 'package:e_chart/src/ext/paint_ext.dart';
import '../../model/string_number.dart';
import 'symbol.dart';

class CircleSymbol extends Symbol {
  final SNumber outerRadius;
  final SNumber innerRadius;
  final Color innerColor;
  final Color outerColor;
  final bool fill;
  final double strokeWidth;

  const CircleSymbol({
    this.innerRadius = SNumber.zero,
    this.outerRadius = const SNumber.percent(100),
    this.innerColor = Colors.blueAccent,
    this.outerColor = Colors.blueAccent,
    this.fill = true,
    this.strokeWidth = 1,
  });

  const CircleSymbol.normal({
    this.outerRadius = const SNumber(100, true),
    Color color = Colors.blueAccent,
  })  : innerRadius = SNumber.zero,
        innerColor = color,
        outerColor = color,
        fill = true,
        strokeWidth = 0;

  @override
  void draw(Canvas canvas, Paint paint, Offset offset, Size size) {
    paint.reset();
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    if (!fill) {
      paint.strokeWidth = strokeWidth;
    }
    paint.color = outerColor;
    double radius = min(size.width, size.height) * 0.5;
    canvas.drawCircle(offset, outerRadius.convert(radius), paint);
    double ir = innerRadius.convert(radius);
    if (ir > 0) {
      paint.color = innerColor;
      canvas.drawCircle(offset, ir, paint);
    }
  }
}
