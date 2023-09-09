import 'dart:ui';
import 'chart_symbol.dart';

class EmptySymbol extends ChartSymbol {
  static final empty = EmptySymbol();

  EmptySymbol();

  @override
  Size get size => const Size(0, 0);

  @override
  void onDraw(Canvas canvas, Paint paint) {}

  @override
  bool contains(Offset center, Offset point) {
    return false;
  }

  @override
  ChartSymbol lerp(covariant ChartSymbol end, double t) {
    return empty;
  }

  @override
  ChartSymbol copy(SymbolAttr? attr) {
    return empty;
  }
}
