import 'dart:ui';

import '../line/line_attrs.dart';

class RadiusAxisAttrs extends LineAxisAttrs {
  final Offset center;
  final num offsetAngle;

  RadiusAxisAttrs(
    this.center,
    this.offsetAngle,
    super.scaleRatio,
    super.scroll,
    super.rect,
    super.start,
    super.end, {
    super.splitCount,
  });

  @override
  RadiusAxisAttrs copyWith({
    double? scaleRatio,
    double? scroll,
    Rect? rect,
    Offset? start,
    Offset? end,
    Offset? center,
    num? offsetAngle,
    int? splitCount,
  }) {
    return RadiusAxisAttrs(
      center ?? this.center,
      offsetAngle ?? this.offsetAngle,
      scaleRatio ?? this.scaleRatio,
      scroll ?? this.scroll,
      rect ?? this.rect,
      start ?? this.start,
      end ?? this.end,
      splitCount: splitCount,
    );
  }
}
