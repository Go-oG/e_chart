import '../chart_tween.dart';
import '../../../src/component/shader/shader.dart';

class ChartShaderTween extends ChartTween<ChartShader> {
  ChartShaderTween(super.begin, super.end,{super.allowCross,super.option});

  @override
  ChartShader convert(double animatorPercent) {
    return begin.lerp( end, animatorPercent);
  }
}
