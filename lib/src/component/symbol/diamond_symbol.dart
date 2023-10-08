import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///棱形
class DiamondSymbol extends ChartSymbol {
  final num shortSide;
  final num longSide;
  final num fixRotate;
  late Path path;

  DiamondSymbol({
    this.shortSide = 8,
    this.longSide = 8,
    this.fixRotate = 0,
    super.borderStyle,
    super.itemStyle,
  }) {
    path = Path();
    path.moveTo(0, -shortSide / 2);
    path.lineTo(longSide / 2, 0);
    path.lineTo(0, shortSide / 2);
    path.lineTo(-longSide / 2, 0);
    path.close();
  }

  @override
  Size get size => Size(longSide.toDouble(), shortSide.toDouble());

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
    canvas.rotate(fixRotate*StaticConfig.angleUnit);
    itemStyle.drawPath(canvas, paint, path);
    borderStyle.drawPath(canvas, paint, path, drawDash: true, needSplit: false);
    canvas.restore();
  }

  Path buildPath(num shortSide, num longSide) {
    double minSize = shortSide / 2;
    double maxSize = longSide / 2;
    Path path = Path();
    path.moveTo(0, -minSize);
    path.lineTo(maxSize, 0);
    path.lineTo(0, minSize);
    path.lineTo(-maxSize, 0);
    path.close();
    return path;
  }

  @override
  DiamondSymbol lerp(covariant DiamondSymbol end, double t) {
    var ss = lerpDouble(shortSide, end.shortSide, t)!;
    var ls = lerpDouble(longSide, end.longSide, t)!;
    var rotate = lerpDouble(fixRotate, end.fixRotate, t)!;
    return DiamondSymbol(
      shortSide: ss,
      longSide: ls,
      fixRotate: rotate,
      itemStyle: AreaStyle.lerp(itemStyle, end.itemStyle, t),
      borderStyle: LineStyle.lerp(borderStyle, end.borderStyle, t),
    );
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    if (attr == null || attr.isEmpty) {
      return this;
    }
    var size = attr.size;
    var ss = size?.shortestSide ?? shortSide;
    var ls = size?.longestSide ?? longSide;
    var r = attr.rotate ?? fixRotate;

    return DiamondSymbol(
      fixRotate: r,
      shortSide: ss,
      longSide: ls,
      itemStyle: itemStyle,
      borderStyle: borderStyle,
    );
  }
}
