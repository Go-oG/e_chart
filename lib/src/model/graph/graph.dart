import 'package:xutil/xutil.dart';

import 'graph_node.dart';

class Graph {
  late final List<GraphNode> nodes;
  late final List<Link<GraphNode>> links;

  Graph(List<GraphNode> nodes, {List<Link<GraphNode>>? links}) {
    this.nodes = [...nodes];
    this.links = [];
    if (links != null) {
      this.links.addAll(links);
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

  Graph addLink(Link<GraphNode> link) {
    if (links.contains(link)) {
      return this;
    }
    this.links.add(link);
    return this;
  }

  Graph removeLink(Link<GraphNode> link) {
    this.links.remove(link);
    return this;
  }

}
