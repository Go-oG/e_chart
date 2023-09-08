import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///正多边形
class PositiveShape implements Shape {
  final Offset center;
  final num r;
  final int count;
  final num angleOffset;

  PositiveShape({
    this.center = Offset.zero,
    this.r = 16,
    this.count = 3,
    this.angleOffset = 0,
  });

  Path? _path;

  @override
  Path toPath() {
    if (_path != null) {
      return _path!;
    }
    Path path = Path();
    _path = path;
    if (count <= 0 || r <= 0) {
      return path;
    }
    double singleAngle = 360 / count;
    for (int j = 0; j < count; j++) {
      num angle = angleOffset + j * singleAngle;
      Offset c = circlePoint(r, angle, center);
      if (j == 0) {
        path.moveTo(c.dx, c.dy);
      } else {
        path.lineTo(c.dx, c.dy);
      }
    }
    path.close();
    return path;
  }

  PositiveShape copy({Offset? center, num? r, int? count, num? angleOffset}) {
    return PositiveShape(
      center: center ?? this.center,
      r: r ?? this.r,
      count: count ?? this.count,
      angleOffset: angleOffset ?? this.angleOffset,
    );
  }

  @override
  bool contains(Offset offset) {
    return toPath().contains(offset);
  }

  static PositiveShape lerp(PositiveShape s, PositiveShape e, double t) {
    var c = Offset.lerp(s.center, e.center, t)!;
    var r = lerpDouble(s.r, e.r, t)!;
    var angle = lerpDouble(s.angleOffset, e.angleOffset, t)!;
    var count = lerpInt(s.count, e.count, t);
    return PositiveShape(count: count, center: c, r: r, angleOffset: angle);
  }

  @override
  bool get isClosed => true;
}
