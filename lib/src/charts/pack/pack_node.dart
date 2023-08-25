import 'package:e_chart/e_chart.dart';

class PackNode extends TreeNode<PackNode> with ViewStateProvider {
  final TreeData data;
  PackProps cur = PackProps(0, 0, 0);
  PackProps start = PackProps(0, 0, 0);
  PackProps end = PackProps(0, 0, 0);

  PackNode(super.parent, this.data, {super.deep, super.maxDeep, super.value});

  static PackNode fromPackData(TreeData data) {
    return toTree<TreeData, PackNode>(data, (p0) => p0.children, (p0, p1) {
      return PackNode(p0, p1, value: p1.value);
    });
  }

  PackProps get props => cur;
}

class PackProps {
  double x;
  double y;
  double r;

  PackProps(this.x, this.y, this.r);

  PackProps copy() {
    return PackProps(x, y, r);
  }

  @override
  String toString() {
    return '[x:${x.toStringAsFixed(2)},y:${y.toStringAsFixed(2)},r:${r.toStringAsFixed(2)}]';
  }
}
