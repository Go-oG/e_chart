import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///小飞机图标(等边三角形实现)
class ArrowSymbol extends ChartSymbol {
  final num sideLength;
  final double ratio;
  final num fixRotate;
  late Path path;
  late Size _size;

  ArrowSymbol({super.borderStyle, super.itemStyle, this.sideLength = 16, this.fixRotate = 0, this.ratio = 0.8}) {
    path = buildPath(sideLength, ratio);
    _size = Size(sideLength * sqrt(3) / 3, sideLength * sqrt(3) / 3);
  }

  @override
  Size get size => _size;

  @override
  bool contains(Offset center, Offset point) {
    return path.contains(point.translate2(center.invert));
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    if (!checkStyle()) {
      return;
    }
    canvas.save();
    canvas.rotate(fixRotate * StaticConfig.angleUnit);
    itemStyle.drawPath(canvas, paint, path);
    borderStyle.drawPath(canvas, paint, path);
    canvas.restore();
  }

  Path buildPath(num sideLength, num ratio) {
    final double sqrt3 = sqrt(3);
    Path path = Path();
    double c = sideLength / 2;
    double tt = sideLength * sqrt3 / 3;
    double tt2 = sideLength * sqrt3 / 6;
    double h = sideLength * sqrt3 / 2;
    path.moveTo(0, -tt);
    path.lineTo(c, tt2);
    path.lineTo(0, tt2 - h * (1 - ratio));
    path.lineTo(-c, tt2);
    path.close();
    return path;
  }

  @override
  ArrowSymbol lerp(covariant ArrowSymbol end, double t) {
    var sl = lerpDouble(sideLength, end.sideLength, t)!;
    var ratio = lerpDouble(this.ratio, end.ratio, t)!;
    var rotate = lerpDouble(fixRotate, end.fixRotate, t)!;
    return ArrowSymbol(
      sideLength: sl,
      fixRotate: rotate,
      ratio: ratio,
      itemStyle: end.itemStyle,
      borderStyle: end.borderStyle,
    );
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    if (attr == null || attr.isEmpty) {
      return this;
    }
    return ArrowSymbol(
      sideLength: attr.size == null ? sideLength : attr.size!.longestSide,
      fixRotate: attr.rotate ?? fixRotate,
      ratio: attr.ratio ?? ratio,
      itemStyle: itemStyle,
      borderStyle: borderStyle,
    );
  }
}
