import '../chart_tween.dart';
import 'package:xchart/src/component/shader/shader.dart';
class ChartShaderTween extends ChartTween<Shader> {
  ChartShaderTween(super.begin, super.end);

  @override
  Shader convert(double animatorPercent) {
    return begin.convert(begin, end, animatorPercent);
  }
}
