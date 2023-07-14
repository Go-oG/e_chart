import 'dart:math';
import 'dart:ui';

import '../style/area_style.dart';
import 'chart_symbol.dart';

///小飞机图标(等边三角形实现)
class ArrowSymbol extends ChartSymbol {
  AreaStyle style;
  num sideLength;
  double ratio;
  num rotate;
  late Path path;

  ArrowSymbol(this.style, {this.sideLength = 16, this.rotate = 0, this.ratio = 0.8, super.center}) {
    updatePath();
  }

  void updatePath() {
    path = Path();
    double c = sideLength / 2;
    double tt = sideLength * sqrt(3) / 3;
    double tt2 = sideLength * sqrt(3) / 6;
    double h = sideLength * sqrt(3) / 2;
    path.moveTo(0, -tt);
    path.lineTo(c, tt2);
    path.lineTo(0, tt2 - h * (1 - ratio));
    path.lineTo(-c, tt2);
    path.close();
  }

  @override
  void draw(Canvas canvas, Paint paint, SymbolDesc info) {
    if (info.center != null && center != info.center) {
      center = info.center!;
    }
    if (info.size != null) {
      sideLength = info.size!.longestSide;
    }
    AreaStyle style = this.style;
    AreaStyle? s = info.toAreaStyle();
    if (s != null) {
      style = s;
    }
    canvas.save();
    canvas.rotate(rotate * pi / 180);
    style.drawPath(canvas, paint, path);
    canvas.restore();
  }

  @override
  Size get size => Size(sideLength * sqrt(3) / 3, sideLength * sqrt(3) / 3);

  @override
  bool internal(Offset point) {
    return path.contains(point.translate(-center.dx, -center.dy));
  }
}
