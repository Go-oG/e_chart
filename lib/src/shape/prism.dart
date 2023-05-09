import 'dart:ui';

import 'shape_element.dart';

///棱形
class Prism implements ShapeElement {
  final Rect rect;

  Prism(this.rect);

  Path? _path;

  @override
  Path path(bool close) {
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
}
