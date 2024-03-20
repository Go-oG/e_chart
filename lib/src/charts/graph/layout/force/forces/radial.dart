import 'dart:math';
import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';
import '../force_fun.dart';

///径向力
class RadialForce extends Force {
  ///节点强度函数
  ///强度决定节点的 x 和 y 速度增加多少。
  ///例如，值为 0.1 表示节点应从其当前位置移动十分之一的距离到每个应用程序的圆上的最近点。
  ///较高的值会将节点更快地移动到目标位置
  ///不建议使用范围 [0,1] 之外的值。
  ForceFun _strengthFun = (node, i, list, w, h) {
    return 0.1;
  };

  ///返回节点位于的圆圈半径大小
  ///相同的半径大小将处于同一个圆
  ForceFun _radiusLevelFun = (node, i, list, w, h) {
    return min(w, h) * 0.5;
  };

  ///存储节点强度
  ///<nodeId,value>
  Map<String, num> _strengthMap = {};

  ///存储节点半径
  ///<nodeId,value>
  Map<String, num> _radiusMap = {};

  double _x = 0, _y = 0;

  ///指定圆心位置 默认(0,0)
  List<SNumber> center;

  RadialForce({
    ForceFun? radiusFun,
    this.center = const [SNumber.zero, SNumber.zero],
    ForceFun? strengthFun,
  }) {
    if (radiusFun != null) {
      _radiusLevelFun = radiusFun;
    }
    if (strengthFun != null) {
      _strengthFun = strengthFun;
    }
    if (center.length != 2) {
      throw FlutterError('center length must ==2');
    }
  }

  List<GraphData> _nodes = [];

  @override
  void initialize(Context context, Graph graph, lcg, num width, num height) {
    super.initialize(context, graph, lcg, width, height);
    _x = center[0].convert(width);
    _y = center[1].convert(height);
    _nodes = graph.nodes;
    _initialize();
  }

  void _initialize() {
    _strengthMap = {};
    _radiusMap = {};
    each(_nodes, (node, i) {
      var d = _radiusLevelFun(node, i, _nodes, width, height);
      _radiusMap[node.id] = d;
      _strengthMap[node.id] = d.isNaN ? 0 : _strengthFun(node, i, _nodes, width, height);
    });
  }

  @override
  void force([double alpha = 1]) {
    each(_nodes, (node, i) {
      var dx = node.x - _x;
      if (dx == 0) {
        dx = 1e-6;
      }
      var dy = node.y - _y;
      if (dy == 0) {
        dy = 1e-6;
      }
      var r = sqrt(dx * dx + dy * dy);
      var k = (_radiusMap[node.id]! - r) * _strengthMap[node.id]! * alpha / r;
      node.vx += dx * k;
      node.vy += dy * k;
    });
  }

  RadialForce setStrength(ForceFun fun) {
    _strengthFun = fun;
    _initialize();
    return this;
  }

  RadialForce setRadius(ForceFun fun) {
    _radiusLevelFun = fun;
    _initialize();
    return this;
  }

  RadialForce x(SNumber v) {
    center[0] = v;
    _x = v.convert(width);
    return this;
  }

  RadialForce y(SNumber v) {
    center[1] = v;
    _y = v.convert(height);
    return this;
  }
}
