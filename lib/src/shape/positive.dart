import 'dart:math';
import 'dart:ui';

import '../ext/offset_ext.dart';
import 'chart_shape.dart';

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
  Path toPath(bool close) {
    if (_path != null) {
      return _path!;
    }
    if (count <= 0) {
      return Path();
    }
    Path path = Path();
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

    _path = path;
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
}
