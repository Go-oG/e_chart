import 'package:e_chart/e_chart.dart';

class AnimationNode extends Disposable {
  final bool autoDispose;
  ChartTween? _tween;
  LayoutType? _type;

  AnimationNode(
    ChartTween tween,
    AnimatorOption attrs,
    LayoutType type, [
    this.autoDispose = true,
  ]) {
    _tween = tween;
    _type = type;
  }

  void start(Context context) {
    var tween = _tween;
    if (isDispose || _type == null || tween == null || tween.isDispose) {
      return;
    }
    var type = _type!;
    if (autoDispose) {
      tween.addEndListener(() {
        tween.dispose();
        _tween = null;
      });
    }
    tween.start(context, type == LayoutType.update);
  }

  void stop() {
    _tween?.stop();
  }

  @override
  void dispose() {
    super.dispose();
    _tween?.stop();
    _tween?.dispose();
    _tween = null;
    _type = null;
  }
}
