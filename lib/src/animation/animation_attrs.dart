import 'package:flutter/animation.dart';

class AnimationAttrs {
  final Duration duration;
  final Duration updateDuration;
  final Duration delay;
  final Duration updateDelay;

  final Curve curve;
  final Curve updateCurve;

  final AnimationBehavior behavior;

  ///动画的阈值(超过该值将不会执行动画)
  final int threshold;

  const AnimationAttrs({
    this.duration = const Duration(milliseconds: 1200),
    this.updateDuration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,

    ///这里默认有个延迟是为了让动画更自然
    this.updateDelay = Duration.zero,
    this.threshold = 2000,
    this.behavior = AnimationBehavior.normal,
    this.curve = Curves.linear,
    this.updateCurve = Curves.linear,
  });
}
