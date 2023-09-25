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
    return toOffset().distance2(o2.toOffset());
  }

  double distance2(Offset o2) {
    return toOffset().distance2(o2);
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
    // TODO: implement toString
    return 'C[${x.toStringAsFixed(0)},${y.toStringAsFixed(0)}]';
  }
}
