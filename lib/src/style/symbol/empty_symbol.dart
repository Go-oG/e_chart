import 'dart:ui';
import 'symbol.dart';

class EmptySymbol extends ChartSymbol {
  EmptySymbol();

  @override
  void draw(Canvas canvas, Paint paint,Offset c, double animator) {
    if (c != center) {
      center = c;
    }
  }

  @override
  Size get size => const Size(0, 0);

  @override
  bool internal(Offset point) {
    return false;
  }
}
