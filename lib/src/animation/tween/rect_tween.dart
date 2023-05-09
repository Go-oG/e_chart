import 'dart:ui';

import 'package:flutter/material.dart';

import '../chart_tween.dart';

class ChartRectTween extends ChartTween<Rect> {
  ChartRectTween(
    super.begin,
    super.end, {
    super.allowCross,
    super.behavior,
    super.curve,
    super.delay,
    super.duration,
    super.lowerBound,
    super.reverseDuration,
    super.upperBound,
  });

  @override
  Rect convert(double animatorPercent) {
    return Rect.lerp(begin, end, animatorPercent)!;
  }
}

class ChartRRectTween extends ChartTween<RRect> {
  ChartRRectTween(super.begin, super.end, {super.allowCross});

  @override
  RRect convert(double animatorPercent) {
    return RRect.lerp(begin, end, animatorPercent)!;
  }
}
