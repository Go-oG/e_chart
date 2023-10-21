import '../render/render_data.dart';

class NodeDiff<N extends RenderData> {
  final N node;
  final NodeAttr startAttr;
  final NodeAttr endAttr;
  final bool old;

  const NodeDiff(this.node, this.startAttr, this.endAttr, this.old);
}
