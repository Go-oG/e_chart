import '../chart_tween.dart';

class ChartDoubleTween extends ChartTween<double> {
  ChartDoubleTween({bool allowCross = false, super.option}) : super(0, 1);

  ChartDoubleTween.fromValue(super._begin, super._end, {bool allowCross = false, super.option});

  @override
  double convert(double animatorPercent) {
    return (begin + (end - begin) * animatorPercent);
  }
}
