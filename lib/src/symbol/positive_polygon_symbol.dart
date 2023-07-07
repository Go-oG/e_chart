import 'dart:ui';
import '../shape/positive.dart';
import '../style/area_style.dart';
import 'chart_symbol.dart';

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
  void draw(Canvas canvas, Paint paint,SymbolDesc info) {
    if (info.center != null && center != info.center) {
      center = info.center!;
    }
    if (info.size != null) {
      r = info.size!.shortestSide*0.5;
    }
    AreaStyle style = this.style;
    AreaStyle? s = info.toStyle();
    if (s != null) {
      style = s;
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
