import 'dart:math';
import 'package:e_chart/src/ext/paint_ext.dart';
import 'package:flutter/material.dart';

import '../../style/area_style.dart';
import 'symbol.dart';

///类似地图当前位置的形状
///TODO 后面贝塞尔曲线拟合
class PinSymbol extends ChartSymbol {
  final AreaStyle style;
  final double r;
  final num rotate;

  const PinSymbol({this.r = 8, this.rotate = 0, this.style = const AreaStyle(color: Colors.blue)});

  @override
  void draw(Canvas canvas, Paint paint, Offset center,double animator) {
    paint.reset();
    Path p1 = Path();
    p1.moveTo(-r, 0);
    p1.arcToPoint(Offset(r, 0), radius: Radius.circular(r), largeArc: true);
    p1.arcToPoint(Offset(-r, 0), radius: Radius.circular(r), largeArc: true);
    p1.close();

    Path p2 = Path();
    p2.moveTo(r, 0);
    Offset bottom = Offset(0, r * 1.2);
    p2.quadraticBezierTo(r * 0.15, r * 0.77, bottom.dx, bottom.dy);
    p2.quadraticBezierTo(-r * 0.15, r * 0.77, -r, 0);
    p2.close();
    p1.addPath(p2, Offset.zero);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotate * pi / 180);
    style.drawPath(canvas, paint, p1);
    canvas.restore();
  }

  @override
  Size get size => Size(r * 2, r * 2.5);
}
