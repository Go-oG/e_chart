
import '../../animation/chart_tween.dart';
import 'layout.dart';

class PieTween extends ChartTween<PieProps> {
  PieTween(super.begin, super.end);

  @override
  PieProps convert(double animatorPercent) {
    PieProps props = PieProps();
    props.corner = begin.corner + (end.corner - begin.corner) * animatorPercent;
    props.ir = begin.ir + (end.ir - begin.ir) * animatorPercent;
    props.or = begin.or + (end.or - begin.or) * animatorPercent;
    props.startAngle = begin.startAngle + (end.startAngle - begin.startAngle) * animatorPercent;
    props.sweepAngle = begin.sweepAngle + (end.sweepAngle - begin.sweepAngle) * animatorPercent;
    return props;
  }
}
