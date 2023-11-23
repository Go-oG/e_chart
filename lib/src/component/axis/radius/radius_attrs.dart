import 'dart:ui';

import '../base/line/line_attrs.dart';

class RadiusAxisAttrs extends LineAxisAttrs {
  Offset center;
  num offsetAngle;

  RadiusAxisAttrs(
    this.center,
    this.offsetAngle,
    super.axisIndex,
    super.rect,
    super.start,
    super.end, {
    super.scaleRatio,
    super.scrollX,
    super.scrollY,
    super.splitCount,
  });

  @override
  RadiusAxisAttrs copy() {
    return RadiusAxisAttrs(
      center,
      offsetAngle,
      axisIndex,
      rect,
      start,
      end,
      scaleRatio: scaleRatio,
      scrollX: scrollX,
      scrollY: scrollY,
      splitCount: splitCount,
    );
  }
}
