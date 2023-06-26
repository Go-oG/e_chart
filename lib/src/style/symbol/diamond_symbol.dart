import 'dart:math';

import 'package:e_chart/src/ext/paint_ext.dart';

import '../../style/area_style.dart';
import 'symbol.dart';
import 'package:flutter/material.dart';

///棱形
class DiamondSymbol extends ChartSymbol {
  final num shortSide;
  final num loneSide;
  final num rotate;
  final AreaStyle style;

  const DiamondSymbol(this.style, {this.shortSide = 8, this.loneSide = 8, this.rotate = 0});

  @override
  void draw(Canvas canvas, Paint paint, Offset center,double animator) {
    paint.reset();
    Path path = Path();
    path.moveTo(0, -shortSide / 2);
    path.lineTo(loneSide / 2, 0);
    path.lineTo(0, center.dy + shortSide / 2);
    path.lineTo(-loneSide / 2, 0);
    path.close();
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotate * pi / 180);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  Size get size => Size(loneSide.toDouble(), shortSide.toDouble());
}
