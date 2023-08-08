import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';


///小飞机图标(等边三角形实现)
class ArrowSymbol extends ChartSymbol {
  final LineStyle? border;
  final AreaStyle style;
  final num sideLength;
  final double ratio;
  final num rotate;
  late final Path path;

  ArrowSymbol(this.style, {this.border, this.sideLength = 16, this.rotate = 0, this.ratio = 0.8}) {
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
  void draw(Canvas canvas, Paint paint, Offset offset) {
    center = offset;
    AreaStyle style = this.style;
    canvas.save();
    canvas.translate(center.dx, center.dy);
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
