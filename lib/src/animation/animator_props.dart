import 'package:flutter/animation.dart';

class AnimatorProps {
  final Duration duration;
  final Duration? reverseDuration;
  final AnimationBehavior behavior;
  final Curve curve;
  final double lowerBound;
  final double upperBound;

  const AnimatorProps({
    this.duration = const Duration(milliseconds: 800),
    this.reverseDuration,
    this.behavior = AnimationBehavior.normal,
    this.curve = Curves.easeInOut,
    this.lowerBound = 0,
    this.upperBound = 1,
  });
}
