import 'dart:ui';
import 'chart_symbol.dart';

class EmptySymbol extends ChartSymbol {
  EmptySymbol();

  @override
  void draw(Canvas canvas, Paint paint,SymbolDesc info) {
    if (info.center != null && center != info.center) {
      center = info.center!;
    }
  }

  @override
  Size get size => const Size(0, 0);

  @override
  bool internal(Offset point) {
    return false;
  }
}
