import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///小飞机图标(等边三角形实现)
class ArrowSymbol extends ChartSymbol {
  LineStyle? border;
  AreaStyle style;
  num sideLength;
  double ratio;
  num rotate;
  late Path path;

  ArrowSymbol(this.style, {this.border, this.sideLength = 16, this.rotate = 0, this.ratio = 0.8}) {
    path = buildPath(sideLength, ratio);
  }

  @override
  Size get size => Size(sideLength * sqrt(3) / 3, sideLength * sqrt(3) / 3);

  @override
  bool internal2(Offset center,Size size,Offset point) {
    final double sqrt3 = sqrt(3);
    double sideLength = size.longestSide;
    double c = sideLength / 2;
    double tt = sideLength * sqrt3 / 3;
    double tt2 = sideLength * sqrt3 / 6;
    double h = sideLength * sqrt3 / 2;
    List<Offset> ol = [
      Offset(0, -tt),
      Offset(c, tt2),
      Offset(0, tt2-h*(1-ratio)),
      Offset(-c, tt2),
      Offset(0, -tt),
    ];
    return point.translate(-center.dx, -center.dy).inPolygon(ol);
  }

  @override
  void draw2(Canvas canvas, Paint paint, Offset offset, Size size) {
    if (this.size != size) {
      sideLength = size.longestSide;
      path = buildPath(sideLength, ratio);
    }
    center = offset;
    AreaStyle style = this.style;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotate * pi / 180);
    style.drawPath(canvas, paint, path);
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
}
