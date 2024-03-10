import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class AngleAxisAttrs extends AxisAttrs {
  Offset center;
  List<double> radius;
  double angleOffset;
  bool clockwise;

  AngleAxisAttrs(
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
