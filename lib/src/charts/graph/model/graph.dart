import '../graph_data.dart';

class Graph {
  late final List<GraphData> nodes;
  late final List<EdgeData> edges;

  Graph(List<GraphData> nodes, {List<EdgeData>? edges}) {
    this.nodes = [...nodes];
    this.edges = [];
    if (edges != null) {
      this.edges.addAll(edges);
    }
  }

  Graph addNode(GraphData node) {
    if (nodes.contains(node)) {
      return this;
    }
    nodes.add(node);
    return this;
  }

  Graph removeNode(GraphData node) {
    nodes.remove(node);
    return this;
  }

  Graph addEdge(EdgeData edge) {
    if (edges.contains(edge)) {
      return this;
    }
    edges.add(edge);
    return this;
  }

  Graph removeEdge(EdgeData edge) {
    edges.remove(edge);
    return this;
  }
}
