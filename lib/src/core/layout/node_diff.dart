import '../data_node.dart';

class NodeDiff<N extends DataNode> {
  final N node;
  final NodeAttr startAttr;
  final NodeAttr endAttr;
  final bool old;

  const NodeDiff(this.node, this.startAttr, this.endAttr, this.old);
}
