import 'dart:ui';

import '../axis_attrs.dart';

class AngleAxisAttrs extends AxisAttrs {
  final Offset center;
  final double radius;
  final double angleOffset;
  final bool clockwise;

  AngleAxisAttrs(
    this.center,
    this.angleOffset,
    this.radius, {
    this.clockwise = true,
  });
}
