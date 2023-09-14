import 'package:e_chart/e_chart.dart';

class AnimationNode {
  final ChartTween tween;
  final AnimatorOption attrs;
  final LayoutType type;

  const AnimationNode(this.tween, this.attrs, this.type);

  void start(Context context) {
    tween.start(context, type == LayoutType.update);
  }

  void stop() {
    tween.stop();
  }

  void dispose() {
    tween.dispose();
  }
}
