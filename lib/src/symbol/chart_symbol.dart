import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///Symbol实现
abstract class ChartSymbol {
  Offset center = Offset.zero;
  ChartSymbol({Offset center = Offset.zero});
  Size get size;

  void draw(Canvas canvas, Paint paint, Offset offset);

  ChartSymbol convert(Set<ViewState> states) {
    return this;
  }

  bool internal(Offset point);

}

