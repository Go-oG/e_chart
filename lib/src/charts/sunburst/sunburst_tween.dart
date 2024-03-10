import 'package:e_chart/e_chart.dart';

class SunburstTween extends ChartTween<Arc> {
  SunburstTween(
    super.begin,
    super.end, {
    bool allowCross = false,
    super.option,
  });

  @override
  Arc convert(double animatorPercent) {
    double innerRadius = begin.innerRadius + (end.innerRadius - begin.innerRadius) * animatorPercent;
    double outerRadius = begin.outRadius + (end.outRadius - begin.outRadius) * animatorPercent;
    double startAngle = begin.startAngle + (end.startAngle - begin.startAngle) * animatorPercent;
    double sweepAngle = begin.sweepAngle + (end.sweepAngle - begin.sweepAngle) * animatorPercent;
 //   double alpha = begin.alpha + (end.alpha - begin.alpha) * animatorPercent;
    return Arc(innerRadius: innerRadius, outRadius: outerRadius, sweepAngle: sweepAngle, startAngle: startAngle);
    //  return Arc(arc, alpha: alpha);
  }
}
