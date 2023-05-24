import 'dart:ui';

///Symbol实现
abstract class ChartSymbol {
  const ChartSymbol();

  Size get size;

  void draw(Canvas canvas, Paint paint, Offset center);

}
