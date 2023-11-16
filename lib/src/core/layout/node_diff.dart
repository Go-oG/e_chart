import '../render/render_data.dart';

class NodeDiff<D extends RenderData> {
  final D data;
  final DataAttr startAttr;
  final DataAttr endAttr;
  final bool old;

  const NodeDiff(this.data, this.startAttr, this.endAttr, this.old);
}
