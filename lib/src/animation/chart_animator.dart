import 'package:flutter/animation.dart';

class ChartAnimator {
  late AnimationController _controller;
  ChartAnimator(
    TickerProvider provider, {
    Duration duration = const Duration(milliseconds: 400),
    Duration? reverseDuration,
    AnimationBehavior behavior = AnimationBehavior.normal,
    Curve curve = Curves.easeInOut,
    double lowerBound = 0,
    double upperBound = 1,
  }) {
    _controller = AnimationController(
      vsync: provider,
      duration: duration,
      reverseDuration: reverseDuration,
      lowerBound: lowerBound,
      upperBound: upperBound,
      animationBehavior: behavior,
    );
  }

  bool get isAnimating => _controller.isAnimating;

  bool get isCompleted => _controller.isCompleted;

  bool get isDismissed => _controller.isDismissed;

  AnimationStatus get status => _controller.status;

  double get value => _controller.value;

  Duration get duration => _controller.duration!;

  void addListener(VoidCallback callback) {
    _controller.addListener(callback);
  }

  void addStatusListener(AnimationStatusListener listener) {
    _controller.addStatusListener(listener);
  }

  void forward({double? from}) {
    _controller.forward(from: from);
  }

  void reverse({double? from}) {
    _controller.reverse(from: from);
  }

  void stop({bool canceled = false}) {
    _controller.stop(canceled: canceled);
  }

  void reVsync(TickerProvider tickerProvider) {
    _controller.resync(tickerProvider);
  }
}
