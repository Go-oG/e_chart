import 'package:e_chart/e_chart.dart';

class ArcTween extends ChartTween<Arc> {
  ArcTween(super.begin, super.end, {super.allowCross, super.props});

  @override
  Arc convert(double animatorPercent) {
    return Arc.lerp(begin, end, animatorPercent);
  }
}
