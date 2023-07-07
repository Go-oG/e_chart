import 'dart:math';
import 'package:flutter/material.dart';

import '../style/area_style.dart';
import 'chart_symbol.dart';

///类似地图当前位置的形状
///TODO 后面贝塞尔曲线拟合
class PinSymbol extends ChartSymbol {
  AreaStyle style;
  double r;
  num rotate;

  PinSymbol({
    this.r = 8,
    this.rotate = 0,
    this.style = const AreaStyle(color: Colors.blue),
    super.center,
  }) {
    buildPath();
  }

  late Path path;

  void buildPath() {
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
    path = p1.shift(center);
  }

  @override
  void draw(Canvas canvas, Paint paint,SymbolDesc info) {
    if (info.center != null && center != info.center) {
      center = info.center!;
    }
    if (info.size != null) {
      r = info.size!.shortestSide*0.5;
      buildPath();
    }

    AreaStyle style = this.style;
    AreaStyle? s = info.toStyle();
    if (s != null) {
      style = s;
    }

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotate * pi / 180);
    canvas.translate(-center.dx, -center.dy);
    style.drawPath(canvas, paint, path);
    canvas.restore();
  }

  @override
  Size get size => Size(r * 2, r * 2.5);

  @override
  bool internal(Offset point) {
    return path.contains(point);
  }


}
