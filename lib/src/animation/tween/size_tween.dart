import 'dart:ui';

import '../chart_tween.dart';

class ChartSizeTween extends ChartTween<Size> {
  ChartSizeTween(super.begin, super.end,{super.allowCross,super.option});

  @override
  Size convert(double animatorPercent) {
    return Size.lerp(begin, end, animatorPercent)!;
  }
}
