import 'dart:async';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 抽象的补间动画
abstract class ChartTween<T> extends ValueNotifier<T> {
  final AnimatorAttrs props;
  AnimationController? _controller;
  T _begin;
  T _end;
  late bool _allowCross;

  ChartTween(
    this._begin,
    this._end, {
    bool allowCross = true,
    this.props = const AnimatorAttrs(),
  }) : super(_begin) {
    _allowCross = allowCross;
  }

  VoidCallback? startListener;
  VoidCallback? endListener;

  bool _hasCallStart = false;
  bool _cancelFlag = false;
  Timer? _waitTimer;

  void start(Context context, [bool useUpdate = false]) {
    var delay = useUpdate ? props.updateDelay : props.delay;
    if (delay.inMilliseconds <= 0) {
      _startInner(context, useUpdate);
      return;
    }
    _cancelFlag = true;
    _waitTimer?.cancel();
    _waitTimer = Timer(delay, () {
      _startInner(context, useUpdate);
    });
  }

  void _startInner(Context context, [bool useUpdate = false]) {
    _hasCallStart = false;
    _cancelFlag = false;
    _controller = context.boundedAnimation(props, useUpdate);
    CurvedAnimation curved = CurvedAnimation(parent: _controller!, curve: useUpdate ? props.updateCurve : props.curve);
    curved.addListener(() {
      if (_cancelFlag) {
        stop();
        return;
      }
      if (!_hasCallStart) {
        _hasCallStart = true;
        startListener?.call();
      }
      value = _getValue(curved.value);
    });
    if (endListener != null) {
      curved.addStatusListener((status) {
        if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
          endListener?.call();
        }
      });
    }
    _controller?.forward();
  }

  double get process => _controller?.value ?? 0;

  void stop() {
    try {
      _waitTimer?.cancel();
      _cancelFlag = true;
      _controller?.stop(canceled: true);
    } catch (e) {
      logPrint('$e');
    }
    _controller = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stop();
    startListener = null;
    endListener = null;
    super.dispose();
  }

  @override
  String toString() {
    return '$runtimeType begin:$begin  end:$end';
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
