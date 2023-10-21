import 'package:e_chart/e_chart.dart';
import '../force_fun.dart';

class XForce extends Force {
  ForceFun _xFun = (a, b, c, w, h) {
    return 0;
  };

  ForceFun _strengthFun = (node, i, list, w, h) {
    return 0.1;
  };
  List<GraphData> _nodes = [];
  Map<String, num> _strengthMap = {};
  Map<String, num> _xzMap = {};

  XForce([ForceFun? xFun]) {
    if (xFun != null) {
      _xFun = xFun;
    }
  }

  @override
  void initialize(Context context, Graph graph, lcg, num width, num height) {
    super.initialize(context, graph, lcg, width, height);
    _nodes = graph.nodes;
    _initialize();
  }

  void _initialize() {
    _strengthMap = {};
    _xzMap = {};
    each(_nodes, (node, i) {
      var v = _xFun(node, i, _nodes, width, height);
      _xzMap[node.id] = v;
      _strengthMap[node.id] = v.isNaN ? 0 : _strengthFun(node, i, _nodes, width, height);
    });
  }

  @override
  void force([double alpha = 1]) {
    for (var node in _nodes) {
      node.vx += (_xzMap[node.id]! - node.x) * _strengthMap[node.id]! * alpha;
    }
  }

  XForce setStrength(ForceFun fun) {
    _strengthFun = fun;
    _initialize();
    return this;
  }

  XForce setX(ForceFun xFun) {
    _xFun = xFun;
    _initialize();
    return this;
  }
}
