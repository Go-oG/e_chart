import 'dart:ui';
import 'package:e_chart/src/ext/offset_ext.dart';

class ChartOffset {
  num x;
  num y;

  ChartOffset(this.x, this.y);

  Offset toOffset() {
    return Offset(x.toDouble(), y.toDouble());
  }

  double distance(ChartOffset o2) {
    return toOffset().distance3(o2.x, o2.y);
  }

  double distance2(Offset o2) {
    return o2.distance3(x, y);
  }

  void add(Offset other) {
    x += other.dx;
    y += other.dy;
  }

  void sub(Offset other) {
    x -= other.dx;
    y -= other.dy;
  }

  @override
  String toString() {
    return 'C[${x.toStringAsFixed(0)},${y.toStringAsFixed(0)}]';
  }
}
