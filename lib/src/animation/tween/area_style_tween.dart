import '../../component/style/area_style.dart';
import '../chart_tween.dart';


class AreaStyleTween extends ChartTween<AreaStyle> {
  AreaStyleTween(
    super.begin,
    super.end, {
    super.allowCross,
    super.props,
  }) {
    changeValue(begin, end);
  }

  @override
  AreaStyle convert(double animatorPercent) {
    return AreaStyle.lerp(begin, end, animatorPercent)!;
  }
}
