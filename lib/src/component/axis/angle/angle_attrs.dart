import 'dart:ui';

import '../axis_attrs.dart';

class AngleAxisAttrs extends AxisAttrs {
  Offset center;
  List<double> radius;
  double angleOffset;
  bool clockwise;

  AngleAxisAttrs(
    super.axisIndex,
    this.center,
    this.angleOffset,
    this.radius, {
    this.clockwise = true,
    super.scaleRatio,
    super.scrollX,
    super.scrollY,
    super.splitCount,
  });

  @override
  AxisAttrs copy() {
    return AngleAxisAttrs(
      axisIndex,
      center,
      angleOffset,
      radius,
      clockwise: clockwise,
      scaleRatio: scaleRatio,
      scrollX: scrollX,
      scrollY: scrollY,
      splitCount: splitCount,
    );
  }
}
