import 'package:flutter/material.dart';
import '../core/context.dart';
import 'chart_tween.dart';

///用于实现播放队列
class TweenSet extends ChartTween<int> {
  ///存放所有的动画
  final List<_TweenNode> _nodeList = [];

  ///存放所有在运行中的动画
  final List<_TweenNode> _runningList = List.empty(growable: true);

  /// 存放所有等待运行的动画
  final List<_TweenNode> _waitRunList = [];

  AnimationController? _controller;

  TweenSet() : super(0, 0) {
    // _ticker = provider.createTicker(_onTickSchedule);
  }

  _TweenNode? _currentNode;

  TweenSet withPlay(ChartTween tween) {
    _TweenNode node = _TweenNode(tween, Duration.zero);
    if (_currentNode == null) {
      _currentNode = node;
    } else {
      node.parent = _currentNode!.parent;
      _currentNode!.siblingList.add(node);
    }
    _nodeList.add(node);
    return this;
  }

  TweenSet afterPlay(ChartTween tween) {
    _TweenNode node = _TweenNode(tween, Duration.zero);
    if (_currentNode == null) {
      _currentNode = node;
    } else {
      node.parent = _currentNode;
      _currentNode!.childList.add(node);
      _currentNode = node;
    }
    _nodeList.add(node);
    return this;
  }

  TweenSet afterDelay(ChartTween tween, Duration delay) {
    _TweenNode node = _TweenNode(tween, delay);
    if (_currentNode == null) {
      _currentNode = node;
    } else {
      node.parent = _currentNode;
      _currentNode!.childList.add(node);
      _currentNode = node;
    }
    _nodeList.add(node);
    return this;
  }

  TweenSet withDelay(ChartTween tween, Duration delay) {
    _TweenNode node = _TweenNode(tween, delay);
    if (_currentNode == null) {
      _currentNode = node;
    } else {
      node.parent = _currentNode!.parent;
      _currentNode!.siblingList.add(node);
    }
    _nodeList.add(node);
    return this;
  }

  @override
  void start(Context context) {
    if (_nodeList.isEmpty) {
      return;
    }
    stop();
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    for (var element in _nodeList) {
      int startTime = element.computeStartTime(force: true);
      if (startTime == nowTime) {
        _runningList.add(element);
      } else if (startTime > nowTime) {
        _waitRunList.add(element);
      } else {
        throw FlutterError('Duration 不能为负值');
      }
    }
    for (var element in _runningList) {
      element.start(context);
    }

    _controller = context.unboundedAnimation();
    _controller?.addListener(() {
      _onTickSchedule(context);
    });
    _controller?.forward();
  }

  @override
  void stop([bool reset = true]) {
    _controller?.stop(canceled: false);
    _waitRunList.clear();
    for (var e in _runningList) {
      e.stop();
    }
    _runningList.clear();
    for (var e in _nodeList) {
      e.stop();
    }
  }

  void _onTickSchedule(Context context) {
    if (_runningList.isEmpty && _waitRunList.isEmpty) {
      stop();
      notifyListeners();
      return;
    }
    int nowTime = DateTime.now().millisecondsSinceEpoch;
    List<_TweenNode> removeList = [];
    List<_TweenNode> remainList = [];
    for (var element in _waitRunList) {
      if (element.computeStartTime() < nowTime) {
        removeList.add(element);
      } else {
        remainList.add(element);
      }
    }
    _waitRunList.clear();
    _waitRunList.addAll(remainList);
    for (var element in removeList) {
      element.tween.start(context);
    }
    _runningList.addAll(removeList);

    //移除已经没运行了的
    _runningList.removeWhere((element) {
      return !element.tween.isAnimating;
    });

    notifyListeners();

    if (_waitRunList.isEmpty) {
      notifyListeners();
      stop();
    }
  }

  @override
  int convert(double animatorPercent) {
    throw UnimplementedError();
  }

  @override
  int get begin => throw UnimplementedError();

  @override
  int get end => throw UnimplementedError();

  @override
  void changeValue(int begin, int end) => throw UnimplementedError();
}

class _TweenNode {
  _TweenNode? parent;
  final List<_TweenNode> childList = [];
  final List<_TweenNode> siblingList = [];
  final Duration delay;
  final ChartTween tween;
  bool running = false;

  _TweenNode(this.tween, this.delay);

  bool _needReComputeStartTime = true;
  int _animationStartTime = 0;

  /// 计算当前动画开始执行时的时间线
  int computeStartTime({
    bool force = false,
  }) {
    if (!_needReComputeStartTime && !force) {
      return _animationStartTime;
    }
    if (parent == null) {
      _animationStartTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      _animationStartTime = parent!.computeStartTime() + parent!.tween.duration.inMilliseconds;
    }
    if (delay.inMilliseconds > 0) {
      _animationStartTime += delay.inMilliseconds;
    }

    _needReComputeStartTime = false;
    return _animationStartTime;
  }

  void start(Context context) {
    running = true;
    tween.start(context);
  }

  void stop() {
    _needReComputeStartTime = true;
    _animationStartTime = 0;
    tween.stop();
  }
}
