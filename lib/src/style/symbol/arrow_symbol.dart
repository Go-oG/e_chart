import 'dart:math';
import 'dart:ui';

import '../../style/area_style.dart';
import 'symbol.dart';

///小飞机图标(等边三角形实现)
class ArrowSymbol extends ChartSymbol {
  final AreaStyle style;
  final num sideLength;
  
  final double ratio;
  final num rotate;
  const ArrowSymbol(
    this.style, {
    this.sideLength = 16,
    this.rotate = 0,
    this.ratio = 0.8,
  });

  @override
  void draw(Canvas canvas, Paint paint, Offset center) {
    Path path = Path();
    double c = sideLength / 2;
    //外接圆半径
    double tt=sideLength*sqrt(3)/3;
    //内接圆半径
    double tt2=sideLength*sqrt(3)/6;
    double h=sideLength*sqrt(3)/2;
    path.moveTo(0, -tt);
    path.lineTo(c,tt2);
    path.lineTo(0, tt2-h*(1-ratio));
    path.lineTo(-c, tt2);
    path.close();

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotate * pi / 180);
    style.drawPath(canvas, paint, path);
    canvas.restore();
  }

  @override
  Size get size => Size(sideLength*sqrt(3)/3, sideLength*sqrt(3)/3);

}
