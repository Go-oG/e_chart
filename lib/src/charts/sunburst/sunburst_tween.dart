
import '../../animation/chart_tween.dart';
import '../../shape/arc.dart';
import 'layout.dart';

class SunburstTween extends ChartTween<SunburstInfo> {
  SunburstTween(
    super.begin,
    super.end, {
    bool allowCross = false,
    super.duration,
    super.reverseDuration,
    super.behavior,
    super.curve,
    super.lowerBound,
    super.upperBound,
    super.delay,
  });

  @override
  SunburstInfo convert(double animatorPercent) {
    double innerRadius = begin.arc.innerRadius + (end.arc.innerRadius - begin.arc.innerRadius) * animatorPercent;
    double outerRadius = begin.arc.outRadius + (end.arc.outRadius - begin.arc.outRadius) * animatorPercent;
    double startAngle = begin.arc.startAngle + (end.arc.startAngle - begin.arc.startAngle) * animatorPercent;
    double sweepAngle = begin.arc.sweepAngle + (end.arc.sweepAngle - begin.arc.sweepAngle) * animatorPercent;
    double alpha = begin.alpha + (end.alpha - begin.alpha) * animatorPercent;
    Arc arc = Arc(innerRadius: innerRadius, outRadius: outerRadius, sweepAngle: sweepAngle, startAngle: startAngle);
    return SunburstInfo(arc, alpha: alpha);
  }
}
