import '../chart_tween.dart';
import 'package:flutter/material.dart';

class ChartTextStyleTween extends ChartTween<TextStyle> {
  ChartTextStyleTween(super.begin, super.end, {super.allowCross, super.option});

  @override
  TextStyle convert(double animatorPercent) {
    return TextStyle.lerp(begin, end, animatorPercent)!;
  }
}
