import 'dart:ui';
import 'chart_symbol.dart';

class EmptySymbol extends ChartSymbol {
  EmptySymbol();

  @override
  void draw(Canvas canvas, Paint paint,Offset offset) {
  }

  @override
  Size get size => const Size(0, 0);

  @override
  bool internal(Offset point) {
    return false;
  }
}
