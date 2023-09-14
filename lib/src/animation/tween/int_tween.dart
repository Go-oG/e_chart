
import '../chart_tween.dart';
class ChartIntTween extends ChartTween<int> {
  ChartIntTween(super.begin, super.end,{super.allowCross,super.option});

  @override
  int convert(double animatorPercent) {
    return (begin + (end - begin) * animatorPercent).round();
  }
}
