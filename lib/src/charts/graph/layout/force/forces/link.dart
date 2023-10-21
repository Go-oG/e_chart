import 'dart:math' as m;

import 'package:e_chart/e_chart.dart';
import '../jiggle.dart';

///链接力(软约束)
///链接力根据所需的链接距离将链接的节点推到一起或分开。
///力的强度与节点之间的距离差异成正比，类似于弹簧力。
class LinkForce extends Force {
  LCG _random = DefaultLCG();

  ///迭代次数，次数越多则节点越稳定
  int _iterations = 1;

  ///距离函数,用于返回两个节点之间的距离
  LinkFun _distanceFun = (link, i, links) => 30;

  ///强度函数
  late LinkFun _strengthFun;

  //==============================
  List<GraphData> _nodes = [];

  List<EdgeData> _links = [];

  ///<linkId-value>
  ///存储每个边之间的强度
  Map<String, num> _strengthsMap = {};

  ///<linkId-value>
  ///存储每个边之间的距离
  Map<String, num> _distancesMap = {};

  ///<linkId-value>
  Map<String, num> _biasMap = {};

  ///存储每个节点的边个数
  ///<nodeId-int>
  Map<String, int> _countMap = {};

  LinkForce({LinkFun? strengthFun, int? iterations, LinkFun? distanceFun}) {
    _strengthFun = strengthFun ??
        (link, i, list) {
          return 1 / m.min(_countMap[link.source.id] ?? 0, _countMap[link.target.id] ?? 0);
        };
    if (iterations != null) {
      _iterations = iterations;
    }
    if (distanceFun != null) {
      _distanceFun = distanceFun;
    }
  }

  @override
  void initialize(Context context, Graph graph, LCG lcg, num width, num height) {
    super.initialize(context, graph, lcg, width, height);
    _nodes = graph.nodes;
    _links = graph.edges;
    _random = lcg;
    _initialize();
  }

  void _initialize() {
    _countMap = {};
    _biasMap = {};
    each(_links, (link, i) {
      link.index = i;
      _countMap[link.source.id] = (_countMap[link.source.id] ?? 0) + 1;
      _countMap[link.target.id] = (_countMap[link.target.id] ?? 0) + 1;
    });
    for (var link in _links) {
      _biasMap[link.id] = _countMap[link.source.id]! / (_countMap[link.source.id]! + _countMap[link.target.id]!);
    }
    _initializeStrength();
    _initializeDistance();
  }

  void _initializeStrength() {
    _strengthsMap = {};
    each(_links, (link, i) {
      _strengthsMap[link.id] = _strengthFun(link, i, _links);
    });
  }

  void _initializeDistance() {
    _distancesMap = {};
    each(_links, (link, i) {
      _distancesMap[link.id] = _distanceFun(link, i, _links);
    });
  }

  @override
  void force([double? alpha]) {
    if (_links.isEmpty) {
      return;
    }
    for (int k = 0; k < _iterations; ++k) {
      each(_links, (link, i) {
        var source = link.source;
        var target = link.target;
        var x = jsOr(target.x + target.vx - source.x - source.vx, jiggle(_random.lcg())).toDouble();
        var y = jsOr(target.y + target.vy - source.y - source.vy, jiggle(_random.lcg())).toDouble();
        var l = m.sqrt(x * x + y * y);
        l = (l - _distancesMap[link.id]!) / l * alpha! * _strengthsMap[link.id]!;
        x = (x * l);
        y = (y * l);
        var b = _biasMap[link.id]!;
        target.vx -= x * b;
        target.vy -= y * b;
        source.vx += x * (b = 1 - b);
        source.vy += y * b;
      });
    }
  }

  LinkForce setLinks(List<EdgeData> links) {
    _links = links;
    _initialize();
    return this;
  }

  LinkForce setIterations(int count) {
    _iterations = count;
    return this;
  }

  LinkForce setStrength(LinkFun fun) {
    _strengthFun = fun;
    _initializeStrength();
    return this;
  }

  LinkForce setDistance(LinkFun fun) {
    _distanceFun = fun;
    _initializeDistance();
    return this;
  }
}

typedef LinkFun = num Function(EdgeData link, int i, List<EdgeData> links);
