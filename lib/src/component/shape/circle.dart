import 'dart:math';
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class Circle extends Shape {
  final num r;
  final Offset center;

  Circle({this.center = Offset.zero, this.r = 0});

  double get x => center.dx;

  double get y => center.dy;

  Path? _path;

  @override
  Path toPath() {
    if (_path != null) {
      return _path!;
    }
    Path path = Path();
    path.moveTo(center.dx + r, center.dy);
    path.arcTo(Rect.fromCircle(center: center, radius: r.toDouble()), 0, 1.9999 * pi, true);
    path.close();
    _path = path;
    return path;
  }

  @override
  bool contains(Offset offset) => offset.inCircle(r, center: center);

  @override
  bool get isClosed => true;

  @override
  void dispose() {
    _path = null;
    super.dispose();
  }
}
