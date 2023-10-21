import 'dart:math';

import 'package:e_chart/e_chart.dart';
import '../force_fun.dart';
import '../jiggle.dart';

///多体力在所有节点之间相互作用(可模拟全局斥力或者重力)
///如果强度是正的，它可以用来模拟重力（吸引力），
///如果强度是负的，它可以用来模拟静电荷（排斥力）。
///此实现使用四叉树和 Barnes–Hut 近似来大大提高性能；可以使用 theta 参数自定义精度。
///与只影响两个链接节点的[LinkForce]不同；
///多体力是全局的。每个节点都会影响其他每个节点，即使它们位于断开连接的子图中。
class ManyBodyForce extends Force {
  LCG _random = DefaultLCG();
  ForceFun _strengthFun = (a, b, c, w, h) {
    return -30;
  };
  num _minDistance = 1;
  num _maxDistanceMax = double.infinity;
  num _theta = 0.81;

  ///========运行中变量========
  Map<String, num> _strengthsMap = {};
  List<GraphData> _nodes = [];

  ManyBodyForce({ForceFun? strengthFun, num? minDistance, num? maxDistance, num? theta}) {
    if (strengthFun != null) {
      _strengthFun = strengthFun;
    }
    _minDistance = minDistance ?? 1;
    _maxDistanceMax = maxDistance ?? double.infinity;
    var t = theta ?? 0.9;
    _theta = t * t;
  }

  @override
  void initialize(Context context, Graph graph, LCG lcg, num width, num height) {
    super.initialize(context, graph, lcg, width, height);
    _nodes = graph.nodes;
    _random = lcg;
    _initialize();
  }

  void _initialize() {
    _strengthsMap = {};
    if (_nodes.isEmpty) {
      return;
    }
    each(_nodes, (node, i) {
      _strengthsMap[node.id] = _strengthFun(node, i, _nodes, width, height);
    });
  }

  @override
  void force([double alpha = 1]) {
    int n = _nodes.length;
    QuadTree<GraphData> tree = QuadTree.simple<GraphData>((d) => d.x, (d) => d.y, _nodes).eachAfter(_accumulate);
    for (int i = 0; i < n; ++i) {
      var node = _nodes[i];
      tree.each((quad, x1, y1, x2, y2) {
        return _apply(quad, x1, y1, x2, y2, node, alpha);
      });
    }
  }

  bool _accumulate(QuadNode<GraphData> quad, x0, y0, x1, y1) {
    num strength = 0;
    num weight = 0;
    QuadNode<GraphData>? q;
    if (quad.hasChild) {
      num x = 0;
      num y = 0;
      num c;
      for (int i = 0; i < 4; ++i) {
        if (isTrue(q = quad[i]) && isTrue((c = q!.extGet('value').abs()))) {
          strength += q.extGet('value');
          weight += c;
          x += c * q.extGet('x');
          y += c * q.extGet('y');
        }
      }
      quad.extSet('x', x / weight);
      quad.extSet('y', y / weight);
    } else {
      q = quad;
      q.extSet('x', q.data!.x);
      q.extSet('y', q.data!.y);
      do {
        strength += _strengthsMap[q!.data?.id]!;
      } while ((q = q.next) != null);
    }
    quad.extSet('value', strength);
    return false;
  }

  bool _apply(QuadNode<GraphData> quad, x1, y1, x2, y2, GraphData node, double alpha) {
    if (!isTrue(quad.extGet('value'))) return true;
    num x = quad.extGet('x') - node.x;
    num y = quad.extGet('y') - node.y;
    num w = x2 - x1;
    num l = x * x + y * y;

    if ((w * w / _theta) < l) {
      if (l < _maxDistanceMax) {
        if (x == 0) {
          x = jiggle(_random.lcg());
          l += x * x;
        }
        if (y == 0) {
          y = jiggle(_random.lcg());
          l += y * y;
        }
        if (l < _minDistance) {
          l = sqrt(_minDistance * l);
        }
        node.vx += x * quad.extGet('value') * alpha / l;
        node.vy += y * quad.extGet('value') * alpha / l;
      }
      return true;
    } else if (quad.hasChild || l >= _maxDistanceMax) {
      return false;
    }

    if (node != quad.data || quad.next != null) {
      if (x == 0) {
        x = jiggle(_random.lcg());
        l += x * x;
      }
      if (y == 0) {
        y = jiggle(_random.lcg());
        l += y * y;
      }
      if (l < _minDistance) {
        l = sqrt(_minDistance * l);
      }
    }
    QuadNode<GraphData>? tmp = quad;
    do {
      if (node != tmp!.data) {
        w = _strengthsMap[tmp.data!.id]! * alpha / l;
        node.vx += x * w;
        node.vy += y * w;
      }
    } while ((tmp = tmp.next) != null);
    return false;
  }

  ManyBodyForce setStrength(ForceFun<GraphData> fun) {
    _strengthFun = fun;
    _initialize();
    return this;
  }

  ///设置最小距离 默认为 1。
  ///最小距离为两个相邻节点之间的力强度建立上限，避免不稳定的状态。
  ///例如当两个节点完全重合时，它会避免无穷大的力
  ///在这种情况下，力的方向是随机的。
  ManyBodyForce setMinDistance(double min) {
    _minDistance = min * min;
    return this;
  }

  ///设置此力的节点之间的最大距离。默认为无穷大。
  ///指定有限的最大距离可以提高性能并生成更好的布局。
  ManyBodyForce setMaxDistance(double max) {
    _maxDistanceMax = max * max;
    return this;
  }

  ///为了加速计算，多体力使用了Barnes–Hut来实现(O(n log n))，
  ///四叉树存储每个节点的当前位置；
  ///对于每个节点，先计算给定节点上所有其他节点的合力。
  ///对于距离很远的节点集群，可以通过将集群视为单个更大的节点来近似计算电荷力。
  ///theta 参数决定了近似精度。
  ///如果四叉树单元格的宽度 w 与节点到单元格质心的距离l的比值:(w/l) 小于 theta，则给定单元格中的所有节点将被作为一个大节点处理。
  ManyBodyForce setTheta(double v) {
    _theta = v * v;
    return this;
  }
}
