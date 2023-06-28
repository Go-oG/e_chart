import 'dart:ui';

import '../../shape/arc.dart';
import '../chart_tween.dart';

class ArcTween extends ChartTween<Arc> {

  ArcTween(super.begin, super.end,{super.allowCross,super.props});

  @override
  Arc convert(double animatorPercent) {
    double innerRadius = begin.innerRadius + (end.innerRadius - begin.innerRadius) * animatorPercent;
    double outerRadius = begin.outRadius + (end.outRadius - begin.outRadius) * animatorPercent;
    double startAngle = begin.startAngle + (end.startAngle - begin.startAngle) * animatorPercent;
    double sweepAngle = begin.sweepAngle + (end.sweepAngle - begin.sweepAngle) * animatorPercent;
    Offset center = Offset.lerp(begin.center, end.center, animatorPercent)!;

    return Arc(
      innerRadius: innerRadius,
      outRadius: outerRadius,
      sweepAngle: sweepAngle,
      startAngle: startAngle,
      center: center,
    );
  }
}
