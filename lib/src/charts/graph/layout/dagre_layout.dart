import 'package:flutter/widgets.dart';
import 'package:e_chart/e_chart.dart';
import 'package:dart_dagre/dart_dagre.dart' as dg;


///层次布局
class DagreLayout extends GraphLayout {
  final bool multiGraph;
  final bool compoundGraph;
  final bool directedGraph;
  final dg.Config config;

  DagreLayout(
    this.config, {
    this.multiGraph = false,
    this.compoundGraph = true,
    this.directedGraph = true,
    super.sizeFun,
    super.nodeSize,
    super.nodeSpaceFun,
    super.sort,
    super.workerThread,
  });

  @override
  void onLayout(LayoutType type) {
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
    List<DagreNode> nodeList = [];
    Map<String, DagreNode> nodeMap = {};
    Map<String, GraphNode> nodeMap2 = {};
    for (var ele in graph.nodes) {
      Size size = getNodeSize(ele);
      DagreNode node = DagreNode(ele.id, size.width, size.height);
      nodeList.add(node);
      nodeMap[ele.id] = node;
      nodeMap2[ele.id] = ele;
    }

    List<DagreEdge> edgeList = [];
    Map<String, Edge<GraphNode>> edgeMap = {};

    for (var e in graph.edges) {
      edgeMap[e.id] = e;
      var source = nodeMap[e.source.id];
      if (source == null) {
        throw FlutterError('无法找到Source');
      }
      var target = nodeMap[e.target.id];
      if (target == null) {
        throw FlutterError('无法找到Target');
      }
      DagreEdge edge = DagreEdge(
        e.id,
        source,
        target,
        minLen: e.minLen,
        weight: e.weight,
        labelOffset: e.labelOffset,
        width: e.width,
        height: e.height,
        labelPos: e.labelPos,
      );
      edgeList.add(edge);
    }

    DagreResult result = dg.layout(
      nodeList,
      edgeList,
      config,
      multiGraph: multiGraph,
      compoundGraph: compoundGraph,
      directedGraph: directedGraph,
    );

    result.nodePosMap.forEach((key, value) {
      var node = nodeMap2[key]!;
      var center = value.center;
      node.x = center.dx;
      node.y = center.dy;
      node.width = value.width;
      node.height = value.height;
    });

    result.edgePosMap.forEach((key, value) {
      var edge = edgeMap[key]!;
      edge.points.clear();
      edge.points.addAll(value.points);
      edge.x = value.x;
      edge.y = value.y;
    });
    notifyLayoutEnd();
  }
}
