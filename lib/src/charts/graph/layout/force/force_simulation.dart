import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:e_chart/e_chart.dart';


class ForceSimulation extends ChartNotifier2 {
  static const int optMaxCount = 25;
  final List<Force> _forces = [];
  final Graph _graph = Graph([], edges: []);
  double _alpha = 1; //类似于模拟退火中的温度
  double _alphaMin = 0.001; //最低温度
  late double _alphaDecay; //温度衰减值只能在[0,1]
  double _alphaTarget = 0;
  double _velocityDecay = 0.6;
  LCG _random = DefaultLCG();

  ///======其它属性=======
  num width = 0;
  num height = 0;
  Context context;

  ///实现动画模拟
  AnimationController? _controller;
  VoidCallback? _end;

  ///性能优化相关的
  bool optPerformance = false;
  int _optCount = 0;

  /// 0为稳定态 1为非稳定态
  int _optSD = 1;

  set onEnd(VoidCallback c) => _end = c;

  ForceSimulation(this.context, Graph graph) {
    _alphaDecay = 1 - pow(_alphaMin, 1 / 300).toDouble();
    setGraph(graph);
  }

  @override
  void dispose() {
    stop();
    for (var value in _forces) {
      try{
        value.onFinish();
      }catch(e){
        Logger.e(e);
      }
    }
    _forces.clear();
    _end = null;
    super.dispose();
  }

  ForceSimulation start() {
    stop();
    _optCount = 0;
    _optSD = 1;

    ///永远不会停止的动画，必须显式调用停止的方法才会停止
    _controller = context.unboundedAnimation();
    _controller?.addListener(() {
      _step();
      if (isRunning && optPerformance && _optSD == 0) {
        _optCount += 1;
      } else {
        _optCount = 0;
      }
      if (_optCount >= optMaxCount) {
        stop();
      }
    });
    _controller?.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _end?.call();
      }
    });
    _controller?.forward();
    return this;
  }

  ForceSimulation restart() {
    _optCount = 0;
    _optSD = 1;
    if (isRunning) {
      return this;
    }
    return start();
  }

  bool get isRunning {
    return _controller != null &&
        (_controller!.status == AnimationStatus.forward || _controller!.status == AnimationStatus.reverse);
  }

  void _step() {
    tick(byUser: false);
    if (hasListeners) {
      notifyListeners();
    }
    if (_alpha < _alphaMin) {
      stop();
    }
  }

  ForceSimulation tick({int iterations = 1, bool byUser = true}) {
    int n = _graph.nodes.length;
    if (n == 0) {
      return this;
    }

    //存储其迭代开始前的旧位置
    Map<GraphData, List<num>> oldPxMap = {};

    for (var k = 0; k < iterations; ++k) {
      _alpha += (_alphaTarget - _alpha) * _alphaDecay;
      for (var value in _forces) {
        value.force(_alpha);
      }
      for (var node in _graph.nodes) {
        if (k == 0 && optPerformance && !byUser) {
          oldPxMap[node] = [node.x, node.y, node.vx, node.vy];
        }
        if (node.fx == null) {
          node.vx *= _velocityDecay;
          node.x += node.vx;
        } else {
          node.x = node.fx!;
          node.vx = 0;
        }
        if (node.fy == null) {
          node.vy *= _velocityDecay;
          node.y += node.vy;
        } else {
          node.y = node.fy!;
          node.vy = 0;
        }
      }
    }

    ///评估稳定性
    if (optPerformance && !byUser) {
      _optSD = _evaluatingStability(oldPxMap) ? 0 : 1;
    } else {
      _optSD = 1;
    }

    return this;
  }

  bool _evaluatingStability(Map<GraphData, List<num>> oldPxMap) {
    int positionCount = 0;
    int velCount = 0;
    double minPixelFactory = 0.9 / context.devicePixelRatio;

    for (var node in _graph.nodes) {
      var nowX = node.x;
      var nowY = node.y;
      var nowVX = node.vx;
      var nowVY = node.vy;
      List<num> oldList = oldPxMap[node]!;
      var oldX = oldList[0];
      var oldY = oldList[1];
      var oldVX = oldList[2];
      var oldVY = oldList[3];

      ///满足位置不在改变
      if ((nowX - oldX).abs() < minPixelFactory && (nowY - oldY).abs() < minPixelFactory) {
        positionCount += 1;
      }

      ///满足速度最小变化量
      if ((nowVX - oldVX).abs() < minPixelFactory && (nowVY - oldVY).abs() < minPixelFactory) {
        velCount += 1;
      }
    }

    int n = _graph.nodes.length;
    if (n <= 20) {
      return (positionCount >= n && velCount >= n);
    }
    int maxN = (n * 0.038).round();
    if (maxN < 2) {
      maxN = 2;
    }
    int c1 = n - positionCount;
    int c2 = n - velCount;
    return c1 <= maxN && c2 <= maxN;
  }

  ForceSimulation stop() {
    if (_controller != null) {
      context.removeAnimation(_controller);
      _controller = null;
    }
    _optCount = 0;
    _optSD = 1;
    return this;
  }

  ForceSimulation nodes(List<GraphData> list) {
    _graph.nodes.clear();
    _graph.nodes.addAll(list);
    _initializeNodes();
    for (var value in _forces) {
      _initializeForce(value);
    }
    return this;
  }

  ForceSimulation setGraph(Graph graph) {
    _graph.nodes.clear();
    _graph.nodes.addAll(graph.nodes);
    _graph.edges.clear();
    _graph.edges.addAll(graph.edges);
    _initializeNodes();
    for (var value in _forces) {
      _initializeForce(value);
    }
    return this;
  }

  ///alpha类似于模拟退火中的温度,它会随着时间的推移而减少。
  ///当alpha达到alphaMin时，模拟停止。
  ///alpha范围为 [0,1]
  ForceSimulation alpha(double value) {
    _alpha = value;
    return this;
  }

  ///设置alphaMin,其范围为[0,1]
  ///当当前的alpha小于alphaMin时，模拟器将停止。
  ForceSimulation alphaMin(double value) {
    _alphaMin = value;
    return this;
  }

  ///设置alpha衰减速率，其范围为[0,1]
  ///alpha衰减率决定了 [_alpha] 插值到 [_alphaTarget] 的速度
  ///由于 [_alphaTarget]默认为零，因此默认情况下它控制模拟冷却的速度。
  ///较高的衰减率会使模拟更快地稳定下来，但有陷入局部最小值的风险；
  ///较低的值会导致模拟运行时间更长，但通常会收敛到更好的布局。
  ///要让模拟在当前[_alpha]下永远运行,则可将 [_alphaDecay]设置为0;或者
  ///将[_alphaTarget] 设置为 大于 [_alphaMin]。
  ForceSimulation alphaDecay(double value) {
    if (value < 0 || value > 1) {
      throw FlutterError('alphaDecay must >=0 and <=1');
    }
    _alphaDecay = value;
    return this;
  }

  ForceSimulation alphaTarget(double value) {
    if (value < 0 || value > 1) {
      throw FlutterError('alphaTarget must >=0 and <=1');
    }
    _alphaTarget = value;
    return this;
  }

  ///设置速度衰减因子，其范围为 [0,1]，默认为 0.6。
  ///衰减因子类似于大气摩擦；在tick期间施加任何力后，每个节点的速度乘以 1- decay。
  ///与[_alphaDecay]一样，较小的[_velocityDecay]可能会收敛到更好的解决方案，但存在数值不稳定和振荡的风险。
  ForceSimulation velocityDecay(double value) {
    if (value < 0 || value > 1) {
      throw FlutterError('velocityDecay must >=0 and <=1');
    }
    _velocityDecay = 1 - value;
    return this;
  }

  ///设置用于生成随机数的函数
  ///这应该是一个返回 [0,1)(不含1)之间数字的函数。
  ///默认为[DefaultLCG]。
  ForceSimulation randomSource(LCG lcg) {
    _random = lcg;
    for (var value in _forces) {
      _initializeForce(value);
    }
    return this;
  }

  ForceSimulation addForce(Force f) {
    removeForce(f);
    _forces.add(_initializeForce(f));
    return this;
  }

  ForceSimulation removeForce(Force f) {
    _forces.remove(f);
    return this;
  }

  GraphData? find(num x, num y, [num? radius]) {
    GraphData? closest;
    if (radius == null) {
      radius = double.infinity;
    } else {
      radius *= radius;
    }
    for (int i = 0; i < _graph.nodes.length; ++i) {
      GraphData node = _graph.nodes[i];
      num dx = x - node.x;
      num dy = y - node.y;
      num d2 = dx * dx + dy * dy;
      if (d2 < radius!) {
        closest = node;
        radius = d2;
      }
    }
    return closest;
  }

  ///初始化节点数据对节点进行索引相关的赋值
  void _initializeNodes() {
    each(_graph.nodes, (node, i) {
      node.index = i;
      if (node.fx != null) {
        node.x = node.fx!;
      }
      if (node.fy != null) {
        node.y = node.fy!;
      }
      if (node.x.isNaN || node.y.isNaN) {
        var radius = _initialRadius * sqrt(0.5 + i), angle = i * _initialAngle;
        node.x = radius * cos(angle);
        node.y = radius * sin(angle);
      }
      if (node.vx.isNaN || node.vy.isNaN) {
        node.vx = node.vy = 0;
      }
    });
  }

  Force _initializeForce(Force force) {
    force.initialize(context, _graph, _random, width, height);
    return force;
  }
}

int _initialRadius = 10;

double _initialAngle = pi * (3 - sqrt(5));
