import 'package:flutter/animation.dart';

class AnimatorAttrs {
  final Duration duration;
  final Duration updateDuration;
  final Duration delay;
  final Duration updateDelay;

  final Curve curve;
  final Curve updateCurve;

  final AnimationBehavior behavior;
  final int threshold;

  const AnimatorAttrs({
    this.duration = const Duration(milliseconds: 1200),
    this.updateDuration = const Duration(milliseconds: 400),
    this.delay = const Duration(milliseconds: 30),  ///这里默认有个延迟是为了让动画更自然
    this.updateDelay = Duration.zero,
    this.threshold = 2000,
    this.behavior = AnimationBehavior.normal,
    this.curve = Curves.easeOutCubic,
    this.updateCurve = Curves.fastEaseInToSlowEaseOut,
  });
}
