import 'package:e_chart/e_chart.dart';
import 'package:flutter/widgets.dart';

class GraphHelper extends LayoutHelper2<GraphData, GraphSeries> {
  GraphHelper(super.context, super.view, super.series);

  Graph graph = Graph([]);
  GraphLayout? _oldLayout;

  @override
  void onLayout(LayoutType type) {
    view.translationX = 0;
    view.translationY = 0;
    var newGraph = initData2(series.nodes, series.edges);
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
  Offset getTranslation() {
    Offset c = _oldLayout?.getTranslation() ?? Offset.zero;
    return c.translate(view.translationX, view.translationY);
  }

  GraphData? _dragNode;

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

  Graph initData2(List<GraphData> nodes, List<EdgeData> links) {
    Set<GraphData> nodeSet = {};
    each(nodes, (data, i) {
      data.index = i;
      data.size = series.getNodeSize(data);
      var symbol = series.getSymbol(context, data);
      data.setSymbol(symbol, true);
      nodeSet.add(data);
    });
    int index = nodes.length;
    List<EdgeData> edgeList = [];
    each(links, (data, i) {
      var source = data.source;
      if (!nodeSet.contains(source)) {
        source.index = index;
        source.size = series.getNodeSize(source);
        var symbol = series.getSymbol(context, source);
        source.setSymbol(symbol, true);
        nodeSet.add(source);
        index += 1;
      }
      var target = data.target;
      if (!nodeSet.contains(target)) {
        target.index = index;
        target.size = series.getNodeSize(target);
        var symbol = series.getSymbol(context, target);
        target.setSymbol(symbol, true);
        nodeSet.add(target);
        index += 1;
      }
      edgeList.add(data);
    });
    List<GraphData> nodeList = List.from(nodeSet);
    nodeList.sort((a, b) => a.dataIndex - b.dataIndex);

    each(nodeSet, (p0, p1) {
      p0.attr.fx = p0.data.fx;
      p0.attr.fy = p0.data.fy;
      p0.attr.weight = p0.data.weight;
    });

    return Graph(nodeList, edges: edgeList);
  }
}
