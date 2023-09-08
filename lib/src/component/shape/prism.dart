import 'dart:ui';

import 'chart_shape.dart';

///棱形
class Prism implements Shape {
  final Rect rect;

  Prism(this.rect);

  Path? _path;

  @override
  Path toPath() {
    if (_path != null) {
      return _path!;
    }
    Path p = Path();
    Offset o = rect.topCenter;
    p.moveTo(o.dx, o.dy);
    o = rect.centerRight;
    p.lineTo(o.dx, o.dy);
    o = rect.bottomCenter;
    p.lineTo(o.dx, o.dy);
    o = rect.centerLeft;
    p.lineTo(o.dx, o.dy);
    p.close();
    _path = p;
    return p;
  }

  @override
  bool contains(Offset offset) {
  return toPath().contains(offset);
  }

  @override
  bool get isClosed => true;
}
