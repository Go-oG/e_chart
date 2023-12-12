import 'dart:ui';

import '../../index.dart';


class RadiusAxisAttrs extends LineAxisAttrs {
  Offset center;
  num offsetAngle;

  RadiusAxisAttrs(
    this.center,
    this.offsetAngle,
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
