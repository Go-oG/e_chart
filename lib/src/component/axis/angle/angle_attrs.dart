import 'dart:ui';

import '../axis_attrs.dart';

class AngleAxisAttrs extends AxisAttrs {
  final Offset center;
  final List<double> radius;
  final double angleOffset;
  final bool clockwise;

  AngleAxisAttrs(this.center, this.angleOffset, this.radius, super.scaleRatio, super.scroll, {this.clockwise = true});

  AngleAxisAttrs copyWith({
    Offset? center,
    double? angleOffset,
    List<double>? radius,
    double? scaleRatio,
    double? scroll,
    bool? clockwise,
  }) {
    return AngleAxisAttrs(
      center ?? this.center,
      angleOffset ?? this.angleOffset,
      radius ?? this.radius,
      scaleRatio ?? this.scaleRatio,
      scroll ?? this.scroll,
      clockwise: clockwise ?? this.clockwise,
    );
  }
}
