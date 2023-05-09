import '../animator_props.dart';
import '../chart_tween.dart';

class ChartDoubleTween extends ChartTween<double> {
  ChartDoubleTween(
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

  ChartDoubleTween.fromAnimator(
    AnimatorProps animator, {
    bool allowCross = false,
  }) : super(
          animator.lowerBound,
          animator.upperBound,
          duration: animator.duration,
          behavior: animator.behavior,
          reverseDuration: animator.reverseDuration,
          curve: animator.curve,
          delay: Duration.zero,
        );

  @override
  double convert(double animatorPercent) {
    return (begin + (end - begin) * animatorPercent);
  }
}
