import 'package:e_chart/e_chart.dart';

class PackNode extends TreeNode<PackNode> with ViewStateProvider implements NodeAccessor<PackAttr, TreeData> {
  final TreeData data;
  PackAttr _attr = PackAttr(0, 0, 0);

  PackNode(super.parent, this.data, {super.deep, super.maxDeep, super.value});

  static PackNode fromPackData(TreeData data) {
    return toTree<TreeData, PackNode>(data, (p0) => p0.children, (p0, p1) {
      return PackNode(p0, p1, value: p1.value);
    });
  }

  PackAttr get props => _attr;

  @override
  TreeData get d => data;

  @override
  PackAttr getP() => _attr;

  @override
  void setP(PackAttr po) => _attr = po;
}

class PackAttr {
  double x;
  double y;
  double r;
  PackAttr(this.x, this.y, this.r);

  PackAttr copy() {
    return PackAttr(x, y, r);
  }

  @override
  String toString() {
    return '[x:${x.toStringAsFixed(2)},y:${y.toStringAsFixed(2)},r:${r.toStringAsFixed(2)}]';
  }
}
