import 'dart:ui';

import '../component/symbol/circle_symbol.dart';
import '../component/symbol/symbol.dart' as sp;

/// 符号描述样式
class SymbolStyle {
  final bool show;
  final sp.Symbol symbol;
  final Size size;
  final double rotate;
  final bool keepAspect = false;
  final Offset offset;

  const SymbolStyle({
    this.show = true,
    this.symbol = const CircleSymbol(),
    this.size = const Size(8, 8),
    this.rotate = 0,
    this.offset = Offset.zero,
  });

  void draw(Canvas canvas, Paint paint, Offset offset, {Size? size}) {
    if (!show) {
      return;
    }
    symbol.draw(canvas, paint, offset, size ?? this.size);
  }

  void draw2(Canvas canvas, Paint paint, List<Offset> offsets) {
    if (!show) {
      return;
    }
    for (var element in offsets) {
      draw(canvas, paint, element);
    }
  }
}
