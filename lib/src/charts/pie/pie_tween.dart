import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PieTween extends ChartTween<Arc> {
  PieTween(super.begin, super.end,{super.allowCross,super.props});

  @override
  Arc convert(double animatorPercent) {
    Offset center;
    if (begin.center == end.center) {
      center = end.center;
    } else {
      center = Offset.lerp(begin.center, end.center, animatorPercent)!;
    }
    num corner = begin.cornerRadius + (end.cornerRadius - begin.cornerRadius) * animatorPercent;
    num ir = begin.innerRadius + (end.innerRadius - begin.innerRadius) * animatorPercent;
    num or = begin.outRadius + (end.outRadius - begin.outRadius) * animatorPercent;
    num startAngle = begin.startAngle + (end.startAngle - begin.startAngle) * animatorPercent;
    num sweepAngle = begin.sweepAngle + (end.sweepAngle - begin.sweepAngle) * animatorPercent;
    num padAngle = begin.padAngle + (end.padAngle - begin.padAngle) * animatorPercent;

    return Arc(
      center: center,
      cornerRadius: corner,
      innerRadius: ir,
      outRadius: or,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      padAngle: padAngle,
    );
  }
}
