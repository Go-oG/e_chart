import 'package:flutter/animation.dart';

class AnimatorProps {
  final Duration duration;
  final Duration updateDuration;
  final Duration delay;
  final Duration updateDelay;

  final Curve curve;
  final Curve updateCurve;

  final AnimationBehavior behavior;
  final int threshold;

  const AnimatorProps({
    this.duration = const Duration(milliseconds: 1200),
    this.updateDuration = const Duration(milliseconds: 350),
    this.delay = Duration.zero,
    this.updateDelay = Duration.zero,
    this.threshold = 2000,
    this.behavior = AnimationBehavior.normal,
    this.curve = Curves.easeOutCubic,
    this.updateCurve = Curves.easeInOutCubic,
  });
}
