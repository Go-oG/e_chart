import 'dart:math';
import 'dart:ui';

import '../../ext/offset_ext.dart';
import '../../style/area_style.dart';
import 'symbol.dart';

///正多边形
class PositivePolygonSymbol extends Symbol {
  final AreaStyle style;
  final int count;
  final num offsetAngle;
  final num rotateAngle;

  const PositivePolygonSymbol(this.style, {this.count=3,this.offsetAngle=0,this.rotateAngle=0});

  @override
  void draw(Canvas canvas, Paint paint, Offset offset, Size size) {
    List<Offset> ol=[];
    double r=min(size.width, size.height)*0.5;
    double singleAngle = 360 / count;
    for (int j = 0; j < count; j++) {
      num angle = offsetAngle - 90 + j * singleAngle;
      ol.add(circlePoint(r,angle,offset));
    }
    style.drawPolygonArea(canvas, paint, ol);
  }
}
