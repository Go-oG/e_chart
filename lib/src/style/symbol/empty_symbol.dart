import 'dart:ui';
import 'symbol.dart';

class EmptySymbol extends ChartSymbol {
  const EmptySymbol();

  @override
  void draw(Canvas canvas, Paint paint, Offset center) {}
  @override
  Size get size => const Size(0,0);
}
