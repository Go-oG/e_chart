import '../chart_tween.dart';
import 'package:flutter/material.dart';

class BoxShadowTween extends ChartTween<BoxShadow> {
  BoxShadowTween(super.begin, super.end);

  @override
  BoxShadow convert(double animatorPercent) {
    return BoxShadow.lerp(begin, end, animatorPercent)!;
  }
}
