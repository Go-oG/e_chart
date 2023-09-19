import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

class GraphHelper extends LayoutHelper2<GraphNode, GraphSeries> {
  GraphHelper(super.context, super.view, super.series);

  Graph graph = Graph([]);
  GraphLayout? _oldLayout;

  @override
  void onLayout(LayoutType type) {
    viewNull?.translationX = 0;
    viewNull?.translationY = 0;
    var newGraph = convertDataToGraph(series.nodes, series.edges);
    var params = GraphLayoutParams(context, series, boxBound, globalBoxBound, width, height);
    _oldLayout?.clearListener();
    _oldLayout = series.layout;
    _oldLayout?.addListener(() {
      var c = _oldLayout?.value;
      if (c != null) {
        value = c;
      }
    });
    _oldLayout?.doLayout(newGraph, params, type);
    graph = newGraph;
    nodeList = graph.nodes;
  }

  @override
  void onRunUpdateAnimation(var list, var animation) {
    notifyLayoutUpdate();
  }

  @override
  SeriesType get seriesType => SeriesType.graph;

  @override
  Offset getTranslation() {
    Offset c = _oldLayout?.getTranslation() ?? Offset.zero;
    return c.translate(view.translationX, view.translationY);
  }

  GraphNode? _dragNode;

  @override
  void onDragStart(Offset offset) {
    var old = offset;
    var center = _oldLayout?.getTranslation() ?? Offset.zero;
    offset = offset.translate(-center.dx, -center.dy).translate(view.translationX.abs(), view.translationY.abs());
    var node = findNode(offset);
    if (node == null && series.onlyDragNode) {
      return;
    }
    if (node != null) {
      _dragNode = node;
      node.fx = offset.dx;
      node.fy = offset.dy;
      node.x = offset.dx;
      node.y = offset.dy;
      node.drawIndex = 100;
      node.addState(ViewState.dragged);
      node.updateStyle(context, series);
      sortList(nodeList);
      notifyLayoutUpdate();
      return;
    }
  }

  @override
  void onDragMove(Offset offset, Offset diff) {
    var node = _dragNode;
    if (node == null && series.onlyDragNode) {
      return;
    }

    if (node == null) {
      view.translationX += diff.dx;
      view.translationY += diff.dy;
      notifyLayoutUpdate();
      return;
    }
    var center = _oldLayout?.getTranslation() ?? Offset.zero;
    double fx = offset.dx - center.dx + view.translationX.abs();
    double fy = offset.dy - center.dy + view.translationY.abs();
    node.fx = fx;
    node.fy = fy;
    node.x = fx;
    node.y = fy;
    notifyLayoutUpdate();
  }

  @override
  void onDragEnd() {
    var node = _dragNode;
    _dragNode = null;
    if (node != null) {
      node.removeState(ViewState.dragged);
      node.updateStyle(context, series);
      node.drawIndex = 0;
      notifyLayoutUpdate();
    }
  }

  Graph convertDataToGraph(List<GraphItemData> nodes, List<EdgeItemData> links) {
    Map<GraphItemData, GraphNode> nodeMap = {};
    Set<ViewState> emptyS = {};
    each(nodes, (data, i) {
      var node = GraphNode(data, i);
      node.index = i;
      node.size = series.getNodeSize(data);
      var symbol = series.getSymbol(context, data, i, node.size, emptyS);
      node.setSymbol(symbol, true);
      nodeMap[data] = node;
    });
    int index = nodeMap.length;
    List<Edge> edgeList = [];
    each(links, (data, i) {
      var source = nodeMap[data.source];
      if (source == null) {
        source = GraphNode(data.source, index);
        source.index = index;
        source.size = series.getNodeSize(source.data);
        var symbol = series.getSymbol(context, source.data, index, source.size, emptyS);
        source.setSymbol(symbol, true);
        nodeMap[data.source] = source;
        index += 1;
      }
      var target = nodeMap[data.target];
      if (target == null) {
        target = GraphNode(data.target, index);
        target.index = index;
        target.size = series.getNodeSize(target.data);
        var symbol = series.getSymbol(context, target.data, index, target.size, emptyS);
        target.setSymbol(symbol, true);
        nodeMap[data.target] = target;
        index += 1;
      }
      edgeList.add(Edge(data, i, source, target));
    });
    List<GraphNode> nodeList = List.from(nodeMap.values);
    nodeList.sort((a, b) => a.dataIndex - b.dataIndex);

    each(nodeMap.values, (p0, p1) {
      p0.attr.fx = p0.data.fx;
      p0.attr.fy = p0.data.fy;
      p0.attr.weight = p0.data.weight;
    });

    return Graph(nodeList, edges: edgeList);
  }
}
