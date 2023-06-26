
import 'dart:ui';
import '../../shape/positive.dart';
import '../../style/area_style.dart';
import 'symbol.dart';

///正多边形
class PositivePolygonSymbol extends ChartSymbol {
  final AreaStyle style;
  final num r;
  final int count;
  final num rotate;

  const PositivePolygonSymbol(this.style, {this.count = 3, this.r = 8, this.rotate = 0});

  @override
  void draw(Canvas canvas, Paint paint, Offset center,double animator) {
    PositiveShape shape = PositiveShape(center: center, r: r, count: count, angleOffset: rotate);
    Path path = shape.toPath(true);
    style.drawPath(canvas, paint, path);
  }

  @override
  Size get size => Size.square(r*2);
}
