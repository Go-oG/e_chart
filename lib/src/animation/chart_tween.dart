import 'dart:async';

import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

/// 图表动画抽象实现
abstract class ChartTween<T> extends ChartNotifier<T> {
  AnimatorOption get option => _option!;
  AnimatorOption? _option;
  AnimationController? _controller;

  T? _begin;
  T? _end;

  late bool _allowCross;

  ChartTween(
    T begin,
    T end, {
    bool allowCross = true,
    AnimatorOption option = AnimatorOption.normal,
  }) : super(begin) {
    _begin = begin;
    _end = end;
    _allowCross = allowCross;
    _option = option;
  }

  final SafeList<VoidCallback> _starListenerList = SafeList();
  final SafeList<VoidCallback> _endListenerList = SafeList();

  void addStartListener(VoidCallback call) {
    _starListenerList.remove(call);
    _starListenerList.add(call);
  }

  void addEndListener(VoidCallback call) {
    _endListenerList.remove(call);
    _endListenerList.add(call);
  }

  bool _hasCallStart = false;
  bool _cancelFlag = false;
  Timer? _waitTimer;

  void start(Context context, [bool useUpdate = false]) {
    if (isDispose) {
      Logger.w("current Object is disposed");
      return;
    }
    var option = _option!;
    var delay = useUpdate ? option.updateDelay : option.delay;
    if (delay.inMilliseconds <= 0) {
      _startInner(context, option, useUpdate);
      return;
    }
    _cancelFlag = true;
    _waitTimer?.cancel();
    _waitTimer = Timer(delay, () {
      _startInner(context, option, useUpdate);
    });
  }

  void _callOnStart() {
    _starListenerList.each((v) {
      try {
        v.call();
      } catch (e) {
        Logger.e(e);
      }
    });
  }

  void _callOnEnd() {
    _endListenerList.each((v) {
      try {
        v.call();
      } catch (e) {
        Logger.e(e);
      }
    });
  }

  void _startInner(Context context, AnimatorOption option, [bool useUpdate = false]) {
    var duration = useUpdate ? option.updateDuration : option.duration;
    if (duration.inMilliseconds <= 0) {
      _callOnStart();
      value = _getValue(1);
      _callOnEnd();
      return;
    }

    _hasCallStart = false;
    _cancelFlag = false;
    _controller = context.boundedAnimation(option, useUpdate);
    var curved = CurvedAnimation(parent: _controller!, curve: useUpdate ? option.updateCurve : option.curve);
    curved.addListener(() {
      if (_cancelFlag) {
        stop();
        return;
      }
      if (!_hasCallStart) {
        _hasCallStart = true;
        _callOnStart();
      }
      value = _getValue(curved.value);
    });
    curved.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _callOnEnd();
      }
    });
    _controller?.forward();
  }

  double get process => _controller?.value ?? 0;

  void stop() {
    try {
      _waitTimer?.cancel();
      _waitTimer = null;
      _cancelFlag = true;
      _controller?.stop(canceled: true);
      _controller?.dispose();
    } catch (e) {
      Logger.e(e);
    }
    _controller = null;
    notifyListeners();
  }

  T get begin => _begin!;

  T get end => _end!;

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

  ///该方法由子类复写且只能在getValue内部调用
  @protected
  T convert(double animatorPercent);

  @override
  void dispose() {
    super.dispose();
    stop();
    _starListenerList.dispose();
    _endListenerList.dispose();
    _option = null;
    _begin = null;
    _end = null;
  }

  @override
  String toString() {
    return '$runtimeType begin:$begin  end:$end';
  }
}
