import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///Symbol实现
abstract class ChartSymbol {
  Offset center = Offset.zero;

  ChartSymbol({Offset center = Offset.zero});

  Size get size;

  void draw(Canvas canvas, Paint paint, Offset offset) {
    draw2(canvas, paint, offset, size);
  }

  void draw2(Canvas canvas, Paint paint, Offset offset, Size size);

  bool internal(Offset point) {
    return internal2(center,size,point);
  }

  bool internal2(Offset center,Size size,Offset point);

  ChartSymbol convert(Set<ViewState> states) {
    return this;
  }
}
