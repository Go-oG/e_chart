import '../chart_tween.dart';
import '../../../src/component/shader/shader.dart';

class ChartShaderTween extends ChartTween<ChartShader> {
  ChartShaderTween(super.begin, super.end,{super.allowCross,super.props});

  @override
  ChartShader convert(double animatorPercent) {
    return begin.lerp( end, animatorPercent);
  }
}
