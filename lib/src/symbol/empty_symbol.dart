import 'dart:ui';
import 'chart_symbol.dart';

class EmptySymbol extends ChartSymbol {
  EmptySymbol();

  @override
  Size get size => const Size(0, 0);

  @override
  void draw2(Canvas canvas, Paint paint, Offset offset, Size size) {}

  @override
  bool internal2(Offset center, Size size, Offset point) {
    return false;
  }
}
