import 'dart:math';
import 'package:e_chart/e_chart.dart';
import '../force_simulation.dart';
import '../force_fun.dart';
import '../jiggle.dart';


///碰撞力节点用于避免节点重叠。
///碰撞力将节点视为具有给定半径的圆，使得节点a 和 b 之间的距离至少为 radius(a) + radius(b)。
///为了减少抖动，默认情况下这是一个具有可配置强度和迭代的“软”约束
class CollideForce extends Force {
  LCG _random = DefaultLCG();

  ///强度值，范围为[0,1] 默认为1。
  ///重叠节点通过迭代松弛来解决。
  ///对于每个节点，先找出在下一个刻于该点重叠的其他节点（使用预期位置 ⟨x + vx,y + vy⟩）；
  ///对每个节点，修改节点的速度以将节点推出重叠区域。
  ///力的强度会抑制速度的变化，因此可以同时将不同的[ForceSimulation]混合在共同使用。
  num _strength = 1;

  ///要迭代的次数，默认为2
  ///增加迭代次数会增加约束的刚性并避免节点部分重叠，但也会增加运行时间。
  int _iterations = 2;

  ///半径函数，返回每个节点的半径大小
  ForceFun<GraphData> _radiusFun = (node, i, nodes, w, h) {
    return 1;
  };

  //============布局过程中的临时变量=====================
  List<GraphData> _nodes = [];

  //存放节点对应的半径
  Map<GraphData, num> _radiusMap = {};

  CollideForce({ForceFun<GraphData>? radiusFun, int? iterations, num? strength}) {
    if (radiusFun != null) {
      _radiusFun = radiusFun;
    }
    if (iterations != null) {
      _iterations = iterations;
    }
    if (strength != null) {
      _strength = strength;
    }
  }

  @override
  void initialize(Context context, Graph graph, LCG lcg, num width, num height) {
    super.initialize(context, graph, lcg, width, height);
    _nodes = graph.nodes;
    _random = lcg;
    _initialize();
  }

  void _initialize() {
    _radiusMap = {};
    if (_nodes.isEmpty) {
      return;
    }
    each(_nodes, (node, i) {
      _radiusMap[node] = _radiusFun(node, i, _nodes, width, height);
    });
  }

  @override
  void force([double alpha = 1]) {
    if (_nodes.isEmpty) {
      return;
    }
    for (int k = 0; k < _iterations; ++k) {
      QuadTree<GraphData> tree = QuadTree.simple<GraphData>((d) => d.x + d.vx, (d) => d.y + d.vy, _nodes).eachAfter(_prepare);
      for (var node in _nodes) {
        var ri = _radiusMap[node]!;
        var ri2 = ri * ri;
        var xi = node.x + node.vx;
        var yi = node.y + node.vy;

        /// tree.visit
        tree.each((quad, x0, y0, x1, y1) {
          var data = quad.data;
          num rj = quad.extGet('r') ?? 0;
          num r = ri + rj;
          if (data != null) {
            if (data.index > node.index) {
              var x = xi - data.x - data.vx, y = yi - data.y - data.vy, l = x * x + y * y;
              if (l < r * r) {
                if (x == 0) {
                  x = jiggle(_random.lcg());
                  l += x * x;
                }
                if (y == 0) {
                  y = jiggle(_random.lcg());
                  l += y * y;
                }
                l = (r - (l = sqrt(l))) / l * _strength;
                node.vx += (x *= l) * (r = (rj *= rj) / (ri2 + rj));
                node.vy += (y *= l) * r;
                data.vx -= x * (r = 1 - r);
                data.vy -= y * r;
              }
            }
            return false;
          }
          return x0 > xi + r || x1 < xi - r || y0 > yi + r || y1 < yi - r;
        });
      }
    }
  }

  bool _prepare(QuadNode<GraphData> quad, num x0, num y0, num x1, num y1) {
    if (quad.data != null) {
      num r = _radiusMap[quad.data]!;
      quad.extSet('r', r);
      return r != 0;
    }
    quad.extSet('r', 0);
    for (int i = 0; i < 4; ++i) {
      var node = quad[i];
      if (node != null && node.extGet('r') > quad.extGet('r')) {
        quad.extSet('r', node.extGet('r'));
      }
    }
    return false;
  }

  CollideForce setIterations(int count) {
    _iterations = count;
    return this;
  }

  CollideForce setStrength(double v) {
    _strength = v;
    return this;
  }

  CollideForce radius(ForceFun<GraphData> fun) {
    _radiusFun = fun;
    _initialize();
    return this;
  }
}
