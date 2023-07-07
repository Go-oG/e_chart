import 'package:e_chart/src/ext/paint_ext.dart';

import '../style/area_style.dart';
import 'chart_symbol.dart';
import 'package:flutter/material.dart';

///棱形
class DiamondSymbol extends ChartSymbol {
  num shortSide;
  num loneSide;
  num rotate;
  AreaStyle style;

  late Path path;

  DiamondSymbol(
    this.style, {
    this.shortSide = 8,
    this.loneSide = 8,
    this.rotate = 0,
  }) {
    buildPath();
  }

  void buildPath() {
    path = Path();
    path.moveTo(0, -shortSide / 2);
    path.lineTo(loneSide / 2, 0);
    path.lineTo(0, center.dy + shortSide / 2);
    path.lineTo(-loneSide / 2, 0);
    path.close();
    path = path.shift(center);
  }

  @override
  set center(Offset o) {
    super.center = o;
    buildPath();
  }

  @override
  void draw(Canvas canvas, Paint paint,SymbolDesc info) {
    if (info.center != null && center != info.center) {
      center = info.center!;
    }
    if (info.size != null) {
      if(info.size!.longestSide!=loneSide){
        loneSide=info.size!.longestSide;
      }
      if(info.size!.shortestSide!=shortSide){
        shortSide=info.size!.shortestSide;
      }
      buildPath();
    }
    AreaStyle style = this.style;
    AreaStyle? s = info.toStyle();
    if (s != null) {
      style = s;
    }
    paint.reset();
    style.drawPath(canvas, paint, path);
  }

  @override
  Size get size => Size(loneSide.toDouble(), shortSide.toDouble());

  @override
  bool internal(Offset point) {
    return path.contains(point);
  }
}
