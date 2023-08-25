import 'edge.dart';
import 'graph_node.dart';

class Graph {
  late final List<GraphNode> nodes;
  late final List<Edge<GraphNode>> edges;

  Graph(List<GraphNode> nodes, {List<Edge<GraphNode>>? edges}) {
    this.nodes = [...nodes];
    this.edges = [];
    if (edges != null) {
      this.edges.addAll(edges);
    }
  }

  Graph addNode(GraphNode node) {
    if (nodes.contains(node)) {
      return this;
    }
    nodes.add(node);
    return this;
  }

  Graph removeNode(GraphNode node) {
    nodes.remove(node);
    return this;
  }

  Graph addEdge(Edge<GraphNode> edge) {
    if (edges.contains(edge)) {
      return this;
    }
    edges.add(edge);
    return this;
  }

  Graph removeEdge(Edge<GraphNode> edge) {
    edges.remove(edge);
    return this;
  }

}
