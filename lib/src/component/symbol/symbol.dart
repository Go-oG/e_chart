import 'dart:ui';

/// 符号枚举
abstract class Symbol {
  const Symbol();

  void draw(Canvas canvas, Paint paint, Offset offset, Size size);

}

