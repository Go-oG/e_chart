import 'package:flutter/material.dart';

import 'chart_animator.dart';

/// 抽象的补间动画
abstract class ChartTween<T> extends ValueNotifier<T> {
  final Duration duration;
  final Duration? reverseDuration;
  final AnimationBehavior behavior;
  final Curve curve;
  final double lowerBound;
  final double upperBound;
  final Duration delay;
  ChartAnimator? _animator;
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

  void start([TickerProvider? provider, bool allowRest = false]) {
    if (provider == null && _animator == null) {
      debugPrint("TickerProvider Is Null Not Allow Run");
      value = end;
      return;
    }

    if (provider == null) {
      _animator!.forward();
      return;
    }

    if (_animator == null) {
      _animator = ChartAnimator(
        provider,
        duration: duration,
        reverseDuration: reverseDuration,
        behavior: behavior,
        curve: curve,
        lowerBound: lowerBound,
        upperBound: upperBound,
      );
      _animator!.addListener(() {
        value = _getValue(_animator?.value ?? 0);
      });
    } else {
      if (allowRest) {
        _animator!.reVsync(provider);
      }
    }
    if (_statusListener != null) {
      _animator!.addStatusListener(_statusListener!);
    }
    _animator!.forward();
  }

  void stop([bool reset = true]) {
    _animator?.stop(canceled: true);
    if (reset) {
      value = end;
    } else {
      notifyListeners();
    }
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

  bool get isAnimating => _animator != null && _animator!.isAnimating;

  bool get isCompleted => _animator != null && _animator!.isCompleted;

  bool get isDismissed => _animator != null && _animator!.isDismissed;

  AnimationStatus get status => _animator?.status ?? AnimationStatus.dismissed;

  void changeValue(T begin, T end) {
    _animator?.stop(canceled: false);
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
