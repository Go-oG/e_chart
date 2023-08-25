import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';


///同心圆布局算法
class ConcentricLayout extends GraphLayout {
  List<SNumber> center = const [SNumber(50, true), SNumber.percent(50)];

  ///是否防止重叠
  bool preventOverlap;

  ///用于处理重叠时的迭代次数
  int maxIterations;

  ///最小节点间距
  num minNodeSpacing;

  ///最小半径间距
  num minRadiusGap;

  /// 每层环之间的距离是否相等
  bool equidistant;

  ///开始的角度
  num startAngle;

  ///扫过的角度(负数为逆时针)
  num sweepAngle;

  ///每层之间最大的间隔；用于限制和确定分层规则
  num? maxLevelDiff;

  ///权重函数
  Fun2<GraphNode, num> weightFun = (a) {
    return a.weight;
  };

  ConcentricLayout({
    this.center = const [SNumber(50, true), SNumber.percent(50)],
    this.minNodeSpacing = 4,
    this.minRadiusGap = 20,
    this.equidistant = false,
    this.startAngle = -90,
    this.sweepAngle = 360,
    this.maxLevelDiff,
    this.preventOverlap = true,
    this.maxIterations = 360,
    Fun2<GraphNode, num>? weightFun,
    super.nodeSize,
    super.nodeSpaceFun,
    super.sizeFun,
    super.workerThread,
  }) {
    if (weightFun != null) {
      this.weightFun = weightFun;
    }
  }

  @override
  void onLayout(LayoutType type) {
    stopLayout();
    clearInterrupt();
    if (workerThread) {
      Future.doWhile(() {
        runLayout(context, series.graph, width, height);
        return false;
      });
    } else {
      runLayout(context, series.graph, width, height);
    }
  }

  void runLayout(Context context, Graph graph, num width, num height) {
    if (graph.nodes.isEmpty) {
      notifyLayoutEnd();
      return;
    }
    List<GraphNode> nodes = graph.nodes;
    int n = graph.nodes.length;
    Offset center = Offset(this.center[0].convert(width), this.center[1].convert(height));
    if (n == 1) {
      nodes[0].x = center.dx;
      nodes[0].y = center.dy;
      notifyLayoutEnd();
      return;
    }

    ///数据分层
    List<List<GraphNode>> levelList = levelData(graph);
    List<LevelInfo> levelInfoList = [];
    num lastRadius = 0;

    ///计算每层最大半径的节点
    List<GraphNode> maxRadiusList = [];
    for (int i = 1; i < levelList.length; i++) {
      checkInterrupt();
      maxRadiusList.add(maxBy<GraphNode>(levelList[i], (p0) => computeRadius(p0)));
    }
    num maxRadius = computeRadius(maxBy<GraphNode>(maxRadiusList, (p0) => computeRadius(p0)));

    ///计算每个分层的半径大小
    for (int i = 0; i < levelList.length; i++) {
      checkInterrupt();
      var level = levelList[i];
      LevelInfo info = LevelInfo();
      levelInfoList.add(info);
      if (i == 0) {
        info.r = computeRadius(level.first) + minRadiusGap;
        lastRadius += info.r;
        continue;
      }
      if (equidistant) {
        ///等间距
        info.r = lastRadius + maxRadius + minRadiusGap;
        lastRadius = info.r + maxRadius;
      } else {
        GraphNode maxNode = maxRadiusList[i - 1];
        num rr = computeRadius(maxNode);
        info.r = lastRadius + rr + minRadiusGap;
        lastRadius = info.r + rr;
      }
    }

    ///布局
    each(levelList, (level, i) {
      checkInterrupt();
      if (i == 0) {
        var node = level.first;
        node.x = center.dx;
        node.y = center.dy;
        return;
      }

      var levelInfo = levelInfoList[i - 1];
      num rr = levelInfo.r;
      num angleInterval = sweepAngle / level.length;
      num angleOffset = startAngle;

      each(level, (node, j) {
        checkInterrupt();
        Offset nc = circlePoint(rr, angleOffset, center);
        if (preventOverlap && j != 0) {
          Offset pre = Offset(level[j - 1].x, level[j - 1].y);
          num sumRadius = computeRadius(node) + computeRadius(level[j - 1]) + minNodeSpacing;
          int c = max([maxIterations, 1]).toInt();
          while (nc.distance2(pre) < sumRadius && c > 0) {
            angleOffset += (sweepAngle < 0) ? -1 : 1;
            nc = circlePoint(rr, angleOffset, center);
            c -= 1;
          }
        }
        angleOffset += angleInterval;
        node.x = nc.dx;
        node.y = nc.dy;
      });
    });
    notifyLayoutEnd();
  }

  @override
  void stopLayout() {
    super.stopLayout();
    interrupt();
  }

  ///对数据分层
  List<List<GraphNode>> levelData(Graph graph) {
    Map<GraphNode, num> weightMap = {};
    for (var c in graph.nodes) {
      checkInterrupt();
      num w = weightFun.call(c);
      if (w < 0) {
        throw FlutterError('权重必须>=0');
      }
      weightMap[c] = w;
    }

    List<GraphNode> nodes = List.from(graph.nodes);
    nodes.sort((a, b) {
      checkInterrupt();
      return weightMap[b]!.compareTo(weightMap[a]!);
    });

    GraphNode maxWeightNode = nodes.first;
    GraphNode minWeightNode = nodes.last;
    num weightDiff = maxLevelDiff ?? -1;
    if (weightDiff <= 0) {
      weightDiff = (weightMap[maxWeightNode]! - weightMap[minWeightNode]!) / 4;
    }

    List<List<GraphNode>> rl = [];
    rl.add([nodes.removeAt(0)]);
    for (var c in nodes) {
      checkInterrupt();
      if (rl.length == 1) {
        rl.add([c]);
        continue;
      }
      List<GraphNode> cl = rl.last;
      num firstWeight = weightMap[cl.first]!;
      num curWeight = weightMap[c]!;
      if ((firstWeight - curWeight).abs() > weightDiff) {
        rl.add([c]);
      } else {
        cl.add(c);
      }
    }
    return rl;
  }

  @override
  Size getNodeSize(GraphNode node) {
    Size size = super.getNodeSize(node);
    double w = min([size.width, size.height]).toDouble();
    return Size.square(w);
  }

  num computeRadius(GraphNode node) {
    return getNodeSize(node).width * 0.5;
  }
}

class LevelInfo {
  num r = 0;
  num angleSpace = 0;
}
