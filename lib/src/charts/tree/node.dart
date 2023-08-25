import 'package:e_chart/e_chart.dart';

class TreeLayoutNode extends TreeNode<TreeLayoutNode> with ViewStateProvider {
  final TreeData data;

  TreeLayoutNode(super.parent, this.data, {super.deep, super.maxDeep, super.value});

  @override
  String toString() {
    return '$data x:${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}';
  }
}
