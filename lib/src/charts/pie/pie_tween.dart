import '../../animation/chart_tween.dart';
import 'layout.dart';

class PieTween extends ChartTween<PieProps> {
  PieTween(super.begin, super.end);

  @override
  PieProps convert(double animatorPercent) {
    num corner = begin.corner + (end.corner - begin.corner) * animatorPercent;
    num ir = begin.ir + (end.ir - begin.ir) * animatorPercent;
    num or = begin.or + (end.or - begin.or) * animatorPercent;
    num startAngle = begin.startAngle + (end.startAngle - begin.startAngle) * animatorPercent;
    num sweepAngle = begin.sweepAngle + (end.sweepAngle - begin.sweepAngle) * animatorPercent;
    return PieProps(corner: corner, ir: ir, or: or, startAngle: startAngle, sweepAngle: sweepAngle);
  }
}
