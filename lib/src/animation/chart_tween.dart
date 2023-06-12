import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 抽象的补间动画
abstract class ChartTween<T> extends ValueNotifier<T> {
  final Duration duration;
  final Duration? reverseDuration;
  final AnimationBehavior behavior;
  final Curve curve;
  final double lowerBound;
  final double upperBound;
  final Duration delay;

  AnimationController? _controller;
  T _begin;
  T _end;

  late bool _allowCross;

  void Function(AnimationStatus)? _statusListener;

  ChartTween(
    this._begin,
    this._end, {
    bool allowCross = false,
    this.duration = const Duration(milliseconds: 800),
    this.reverseDuration,
    this.behavior = AnimationBehavior.normal,
    this.curve = Curves.easeInOut,
    this.lowerBound = 0,
    this.upperBound = 1,
    this.delay = Duration.zero,
  }) : super(_begin) {
    _allowCross = allowCross;
  }

  void start(Context context) {
    stop();
    AnimatorProps props = AnimatorProps(
      duration: duration,
      reverseDuration: reverseDuration,
      behavior: behavior,
      curve: curve,
      lowerBound: lowerBound,
      upperBound: upperBound,
    );
    _controller = context.boundedAnimation(props);
    _controller!.addListener(() {
      value = _getValue(_controller?.value ?? 0);
    });
    if (_statusListener != null) {
      _controller!.addStatusListener(_statusListener!);
    }
    _controller!.forward();
  }

  void stop() {
    try {
      _controller?.stop(canceled: true);
    } catch (e) {
      debugPrint('$e');
    }
    _controller = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  @override
  String toString() {
    return '$runtimeType begin:$begin  end:$end';
  }

  set statusListener(void Function(AnimationStatus)? fun) {
    _statusListener = fun;
  }

  T get begin => _begin;

  T get end => _end;

  bool get isAnimating => _controller != null && _controller!.isAnimating;

  bool get isCompleted => _controller != null && _controller!.isCompleted;

  bool get isDismissed => _controller != null && _controller!.isDismissed;

  AnimationStatus get status => _controller?.status ?? AnimationStatus.dismissed;

  void changeValue(T begin, T end) {
    _controller?.stop(canceled: false);
    _begin = begin;
    _end = end;
    value = begin;
  }

  void update(double t) {
    value = _getValue(t);
  }

  T _getValue(double t) {
    if (begin == end) {
      return end;
    }
    if (!_allowCross) {
      if (t >= 1) {
        return end;
      }
      if (t <= 0) {
        return begin;
      }
    }
    return convert(t);
  }

  T safeGetValue(double t) {
    return _getValue(t);
  }

  ///该方法由子类复写且只能在getValue内部调用
  @protected
  T convert(double animatorPercent);
}
