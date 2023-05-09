import 'dart:ui';
import 'symbol.dart';

class EmptySymbol extends Symbol {
  const EmptySymbol();

  @override
  void draw(Canvas canvas, Paint paint, Offset offset, Size size) {}
}
