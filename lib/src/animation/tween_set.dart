import 'dart:async';

import '../core/context.dart';
import 'chart_tween.dart';

///用于实现多个动画的执行
class TweenSet extends ChartTween<int> {
  List<Timer> _timerList = [];

  TweenSet() : super(0, 0);

  TweenNode? _rootNode;

  TweenNode? _currentNode;

  TweenSet withPlay(ChartTween tween) {
    TweenNode node = TweenNode(tween, Duration.zero);
    if (_currentNode == null) {
      _currentNode = node;
      _rootNode = node;
    } else {
      node.parent = _currentNode!.parent;
      _currentNode!.siblingList.add(node);
    }
    return this;
  }

  TweenSet afterPlay(ChartTween tween) {
    TweenNode node = TweenNode(tween, Duration.zero);
    if (_currentNode == null) {
      _currentNode = node;
      _rootNode = node;
    } else {
      node.parent = _currentNode;
      _currentNode!.childList.add(node);
      _currentNode = node;
    }
    return this;
  }

  TweenSet afterDelay(ChartTween tween, Duration delay) {
    TweenNode node = TweenNode(tween, delay);
    if (_currentNode == null) {
      _currentNode = node;
      _rootNode = node;
    } else {
      node.parent = _currentNode;
      _currentNode!.childList.add(node);
      _currentNode = node;
    }
    return this;
  }

  TweenSet withDelay(ChartTween tween, Duration delay) {
    TweenNode node = TweenNode(tween, delay);
    if (_currentNode == null) {
      _currentNode = node;
      _rootNode = node;
    } else {
      node.parent = _currentNode!.parent;
      _currentNode!.siblingList.add(node);
    }
    return this;
  }

  @override
  void start(Context context, [bool useUpdate = false]) {
    if (_rootNode == null) {
      return;
    }
    var root = _rootNode!;
    Set<TweenNode> nodeSet = {};
    List<TweenNode> nodeList = [root];
    List<TweenNode> next = [];
    while (nodeList.isEmpty) {
      for (var n in nodeList) {
        nodeSet.add(n);
        next.addAll(n.siblingList);
        next.addAll(n.childList);
      }
      nodeList = next;
      next = [];
    }

    ///计算执行时间
    for (var node in nodeSet) {
      node.computeStartTime(force: false);
    }
    int now = DateTime.now().millisecondsSinceEpoch;
    List<Timer> timerList = [];
    for (var node in nodeSet) {
      int sub = node.computeStartTime(force: false) - now;
      if (sub <= 0) {
        node.start(context);
      } else {
        Timer timer = Timer(Duration(milliseconds: sub), () {
          node.start(context);
        });
        timerList.add(timer);
      }
    }
    _timerList = timerList;
  }

  @override
  void stop([bool reset = true]) {
    if (_timerList.isEmpty) {
      return;
    }
    for (var timer in _timerList) {
      timer.cancel();
    }
    _timerList.clear();
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

class TweenNode {
  TweenNode? parent;
  final List<TweenNode> childList = [];
  final List<TweenNode> siblingList = [];
  final Duration delay;
  final ChartTween tween;
  bool running = false;

  TweenNode(this.tween, this.delay);

  bool _needReComputeStartTime = true;
  int _animationStartTime = 0;

  /// 计算当前动画开始执行时的时间线
  int computeStartTime({bool force = false}) {
    if (!_needReComputeStartTime && !force) {
      return _animationStartTime;
    }
    if (parent == null) {
      _animationStartTime = DateTime.now().millisecondsSinceEpoch;
    } else {
      _animationStartTime = parent!.computeStartTime() + parent!.tween.props.duration.inMilliseconds;
    }
    if (delay.inMilliseconds > 0) {
      _animationStartTime += delay.inMilliseconds;
    }
    _needReComputeStartTime = false;
    return _animationStartTime;
  }

  void start(Context context) {
    running = true;
    tween.addEndListener(() {
      running = false;
    });
    tween.start(context);
  }

  void stop() {
    _needReComputeStartTime = true;
    _animationStartTime = 0;
    tween.stop();
  }
}
