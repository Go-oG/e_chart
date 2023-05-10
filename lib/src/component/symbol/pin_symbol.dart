import 'dart:ui';

import 'package:e_chart/src/ext/paint_ext.dart';

import 'symbol.dart';

class PinSymbol extends Symbol {
  final Color color;
  final bool fill;
  final double strokeWidth;

  const PinSymbol(this.color, {this.fill = true, this.strokeWidth = 0});

  @override
  void draw(Canvas canvas, Paint paint, Offset offset, Size size) {
    paint.reset();
    paint.color = color;
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    paint.strokeWidth = strokeWidth;
    Path path = Path();
    path.moveTo(offset.dx, offset.dy - size.height / 2);
    path.lineTo(offset.dx + size.width / 2, offset.dy);
    path.lineTo(offset.dx, offset.dy + size.height / 2);
    path.lineTo(offset.dx - size.width / 2, offset.dy);
    path.close();
    canvas.drawPath(path, paint);
  }
}
