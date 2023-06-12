import 'dart:ui';

import '../../animation/chart_tween.dart';
import 'layout.dart';

class PieTween extends ChartTween<PieProps> {
  PieTween(super.begin, super.end);

  @override
  PieProps convert(double animatorPercent) {
    Offset center;
    if (begin.center == end.center) {
      center = end.center;
    } else {
      center = Offset.lerp(begin.center, end.center, animatorPercent)!;
    }
    num corner = begin.corner + (end.corner - begin.corner) * animatorPercent;
    num ir = begin.ir + (end.ir - begin.ir) * animatorPercent;
    num or = begin.or + (end.or - begin.or) * animatorPercent;
    num startAngle = begin.startAngle + (end.startAngle - begin.startAngle) * animatorPercent;
    num sweepAngle = begin.sweepAngle + (end.sweepAngle - begin.sweepAngle) * animatorPercent;
    return PieProps(center: center, corner: corner, ir: ir, or: or, startAngle: startAngle, sweepAngle: sweepAngle);
  }
}
