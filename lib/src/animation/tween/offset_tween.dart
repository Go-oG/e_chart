import 'dart:ui';

import '../chart_tween.dart';

class OffsetTween extends ChartTween<Offset> {
  OffsetTween(super.begin, super.end,{super.allowCross,super.props});

  @override
  Offset convert(double animatorPercent) {
    return Offset.lerp(begin, end, animatorPercent)!;
  }
}
