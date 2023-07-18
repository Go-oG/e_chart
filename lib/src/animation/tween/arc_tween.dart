import '../../shape/arc.dart';
import '../chart_tween.dart';

class ArcTween extends ChartTween<Arc> {

  ArcTween(super.begin, super.end,{super.allowCross,super.props});

  @override
  Arc convert(double animatorPercent) {
    return Arc.lerp(begin, end, animatorPercent);
  }
}
