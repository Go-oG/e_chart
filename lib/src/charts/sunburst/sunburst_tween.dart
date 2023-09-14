
import 'package:e_chart/e_chart.dart';
import 'sunburst_node.dart';

class SunburstTween extends ChartTween<SunburstAttr> {
  SunburstTween(
    super.begin,
    super.end, {
    bool allowCross = false,
    super.option,
  });

  @override
  SunburstAttr convert(double animatorPercent) {
    double innerRadius = begin.arc.innerRadius + (end.arc.innerRadius - begin.arc.innerRadius) * animatorPercent;
    double outerRadius = begin.arc.outRadius + (end.arc.outRadius - begin.arc.outRadius) * animatorPercent;
    double startAngle = begin.arc.startAngle + (end.arc.startAngle - begin.arc.startAngle) * animatorPercent;
    double sweepAngle = begin.arc.sweepAngle + (end.arc.sweepAngle - begin.arc.sweepAngle) * animatorPercent;
    double alpha = begin.alpha + (end.alpha - begin.alpha) * animatorPercent;
    Arc arc = Arc(innerRadius: innerRadius, outRadius: outerRadius, sweepAngle: sweepAngle, startAngle: startAngle);
    return SunburstAttr(arc, alpha: alpha);
  }
}
