import 'dart:math';
import 'dart:ui';

import 'shape_element.dart';

class Circle implements ShapeElement {
  final num r;
  final Offset center;

  Circle({this.center = Offset.zero, this.r = 0});

  double get x => center.dx;

  double get y => center.dy;

  Path? _path;

  @override
  Path path(bool close) {
    if (_path != null) {
      return _path!;
    }
    Path path = Path();
    path.moveTo(center.dx, center.dy - r);
    path.arcTo(Rect.fromCircle(center: center, radius: r.toDouble()), -90 * pi / 180, 359.999 * pi / 180, true);
    path.close();
    _path = path;
    return path;
  }
}
