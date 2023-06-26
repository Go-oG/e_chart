import '../chart_tween.dart';
import 'package:flutter/material.dart';

class BoxShadowTween extends ChartTween<BoxShadow> {
  BoxShadowTween(super.begin, super.end,{super.allowCross,super.props});

  @override
  BoxShadow convert(double animatorPercent) {
    return BoxShadow.lerp(begin, end, animatorPercent)!;
  }
}
