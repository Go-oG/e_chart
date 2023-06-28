import '../chart_tween.dart';
import '../../../src/component/shader/shader.dart';

class ChartShaderTween extends ChartTween<Shader> {
  ChartShaderTween(super.begin, super.end,{super.allowCross,super.props});

  @override
  Shader convert(double animatorPercent) {
    return begin.convert(begin, end, animatorPercent);
  }
}
