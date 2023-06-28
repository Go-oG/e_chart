import 'dart:ui';
import '../../shape/positive.dart';
import '../../style/area_style.dart';
import 'symbol.dart';

///正多边形
class PositivePolygonSymbol extends ChartSymbol {
  AreaStyle style;
  num r;
  int count;
  num rotate;

  PositivePolygonSymbol(
    this.style, {
    this.count = 3,
    this.r = 8,
    this.rotate = 0,
    super.center,
  }) {
    buildPath();
  }

  late Path path;

  void buildPath() {
    PositiveShape shape = PositiveShape(center: center, r: r, count: count, angleOffset: rotate);
    path = shape.toPath(true);
  }

  @override
  set center(Offset o) {
    super.center = o;
    buildPath();
  }

  @override
  void draw(Canvas canvas, Paint paint,Offset c,  double animator) {
    if (c != center) {
      center = c;
    }
    style.drawPath(canvas, paint, path);
  }

  @override
  Size get size => Size.square(r * 2);

  @override
  bool internal(Offset point) {
    return path.contains(point);
  }
}
