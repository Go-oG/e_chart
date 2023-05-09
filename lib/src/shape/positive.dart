import 'dart:math';
import 'dart:ui';

import 'shape_element.dart';

///正多边形
class PositiveShape implements ShapeElement {
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
  Path path(bool close) {
    if (_path != null) {
      return _path!;
    }
    Path path = Path();
    double singleAngle = 360 / count;
    for (int j = 0; j < count; j++) {
      num angle = angleOffset - 90 + j * singleAngle;
      double radians = angle * pi / 180;
      double x = -r * cos(radians);
      double y = r * sin(radians);
      if (j == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
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
