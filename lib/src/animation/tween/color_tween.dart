import 'dart:ui';

import '../chart_tween.dart';
import 'package:flutter/animation.dart';

class ChartColorTween extends ChartTween<Color> {
  ChartColorTween(super.begin, super.end,{super.allowCross,super.props});

  @override
  Color convert(double animatorPercent) {
    return Color.lerp(begin, end, animatorPercent)!;
  }
}
