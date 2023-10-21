import 'dart:math' as m;
import 'dart:ui';

import 'package:e_chart/e_chart.dart';

///环形布局
class CircularLayout extends GraphLayout {
  List<SNumber> center;

  ///当设置了Radius时 startRadius 和endRadius 将被忽略
  SNumber? radius;
  SNumber? startRadius;
  SNumber? endRadius;

  ///开始角度
  num startAngle;

  ///扫过的角度(负数为逆时针)
  num sweepAngle;

  CircularLayout({
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radius,
    this.startRadius,
    this.endRadius,
    this.startAngle = 90,
    this.sweepAngle = 360,
    super.nodeSpaceFun,
    super.sort,
    super.workerThread,
  });

  Offset _center = Offset.zero;

  @override
  void onLayout(Graph graph, GraphLayoutParams params, LayoutType type) {
    var width = params.width;
    var height = params.height;
    _center = Offset(center[0].convert(width), center[1].convert(height));

    var nodes = graph.nodes;
    int nodeCount = nodes.length;
    if (nodeCount == 0) {
      return;
    }

    if (nodeCount == 1) {
      nodes[0].x = _center.dx;
      nodes[0].y = _center.dy;
      notifyLayoutEnd();
      return;
    }

    List<num> radiusList = computeRadius(graph, width, height);

    ///角度递增量
    var angleStep = sweepAngle / (nodeCount - 1);

    ///节点排序
    List<GraphData> layoutNodes = nodes;
    sortNode(graph, layoutNodes);
    each(layoutNodes, (node, i) {
      num r = radiusList[0] + radiusList[2] * i;
      num tmp = angleStep * i;
      num angle = startAngle + tmp;
      Offset off = circlePoint(r, angle, _center);
      node.x = off.dx;
      node.y = off.dy;
    });
    notifyLayoutEnd();
  }

  @override
  void sortNode(Graph graph, List<GraphData> list, [bool asc = false]) {
    Map<GraphData, num> sortMap;
    if (sort != null) {
      sortMap = sort!.call(list);
    } else {
      sortMap = _defaultSort(graph);
    }
    list.sort((a, b) {
      num av = sortMap[a] ?? 0;
      num bv = sortMap[b] ?? 0;
      return bv.compareTo(av);
    });
  }

  ///计算半径
  List<num> computeRadius(Graph graph, num width, num height) {
    var nodes = graph.nodes;
    num startR;
    num endR;
    num rStep;
    num size = m.min(width, height);
    if (radius != null) {
      num mv = radius!.convert(size);
      startR = endR = mv;
      rStep = 0;
    } else {
      if (startRadius != null) {
        startR = startRadius!.convert(size);
      } else {
        startR = size * 0.5;
      }
      if (endRadius != null) {
        endR = endRadius!.convert(size);
      } else {
        endR = size * 0.5;
      }
      if (startR > endR) {
        var t = endR;
        endR = startR;
        startR = t;
      }
      if (nodes.length <= 1) {
        rStep = 1;
      } else {
        rStep = (endR - startR) / (nodes.length - 1);
      }
    }
    return [startR, endR, rStep];
  }
}

Map<GraphData, num> _defaultSort(Graph graph, [int type = 0]) {
  ///按照度排列
  Map<GraphData, Degree> degreeMap = {};
  for (var element in graph.edges) {
    var source = element.source;
    Degree degree = degreeMap[source] ?? Degree();
    degreeMap[source] = degree;
    degree.out += 1;
    degree.all += 1;

    var target = element.target;
    degree = degreeMap[target] ?? Degree();
    degreeMap[target] = degree;
    degree.inter += 1;
    degree.all += 1;
  }
  Map<GraphData, num> map = {};
  degreeMap.forEach((key, value) {
    if (type == 0) {
      map[key] = value.all;
    } else if (type == 1) {
      map[key] = value.inter;
    } else {
      map[key] = value.out;
    }
  });
  return map;
}

class Degree {
  num inter = 0;
  num out = 0;
  num all = 0;
}
