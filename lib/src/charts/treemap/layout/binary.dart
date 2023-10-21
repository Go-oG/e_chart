import 'dart:ui';
import 'package:e_chart/e_chart.dart';

/// 近似平衡二叉树排列
/// 为宽矩形选择水平分区，为高矩形选择垂直分区的布局方式。
/// 由于权重只能为int 因此内部会进行相关的double->int的转换
class BinaryLayout extends TreemapLayout {
  @override
  void onLayout2(TreeMapData root, LayoutType type) {
    Rect area = boxBound;
    BinaryNode binaryNode = _convertToBinaryNode(null, root, false);
    binaryNode.x = area.center.dx;
    binaryNode.y = area.center.dy;
    binaryNode.size = area.size;
    _layoutChildren(area, binaryNode);
    for (var node in binaryNode.children) {
      Rect rect = Rect.fromCenter(center: node.center, width: node.size.width, height: node.size.height);
      node.layoutNode.attr = rect;
    }
  }

  void _layoutChildren(Rect area, BinaryNode parent) {
    List<BinaryNode> nodeList = parent.children;
    if (nodeList.isEmpty) {
      return;
    }
    List<double> sumList = [0];
    for (var element in nodeList) {
      sumList.add(element.value + sumList.last);
    }

    _partition(
      sumList,
      nodeList,
      0,
      nodeList.length,
      parent.value,
      area.left,
      area.top,
      area.right,
      area.bottom,
    );
  }

  static BinaryNode _convertToBinaryNode(BinaryNode? parent, TreeMapData layoutNode, bool exit) {
    BinaryNode node = BinaryNode(parent, [], Rect.zero, layoutNode);
    if (!exit) {
      for (TreeMapData element in layoutNode.children) {
        node.add(_convertToBinaryNode(node, element, true));
      }
    }
    return node;
  }

  ///分割
  static void _partition(
    List<double> sums,
    List<BinaryNode> nodes,
    int start,
    int end,
    num value,
    num left,
    num top,
    num right,
    num bottom,
  ) {
    //无法再分割直接返回
    if (start >= end - 1) {
      BinaryNode node = nodes[start];
      Rect rect = Rect.fromLTRB(
        left.toDouble(),
        top.toDouble(),
        right.toDouble(),
        bottom.toDouble(),
      );
      node.x = rect.center.dx;
      node.y = rect.center.dy;
      node.size = rect.size;
      return;
    }
    double valueOffset = sums[start];
    double valueTarget = (value / 2) + valueOffset;
    int k = start + 1;
    int hi = end - 1;

    while (k < hi) {
      int mid = k + hi >>> 1;
      if (sums[mid] < valueTarget) {
        k = mid + 1;
      } else {
        hi = mid;
      }
    }

    if ((valueTarget - sums[k - 1]) < (sums[k] - valueTarget) && start + 1 < k) {
      --k;
    }

    double valueLeft = sums[k] - valueOffset;
    double valueRight = value - valueLeft;

    if ((right - left) > (bottom - top)) {
      //宽矩形水平分割
      var xk = (left * valueRight + right * valueLeft) / value;
      _partition(sums, nodes, start, k, valueLeft, left, top, xk, bottom);
      _partition(sums, nodes, k, end, valueRight, xk, top, right, bottom);
    } else {
      // 高矩形垂直分割
      var yk = (top * valueRight + bottom * valueLeft) / value;
      _partition(sums, nodes, start, k, valueLeft, left, top, right, yk);
      _partition(sums, nodes, k, end, valueRight, left, yk, right, bottom);
    }
  }
}

class BinaryNode extends BaseTreeData<Rect, BinaryNode> {
  final TreeMapData layoutNode;

  BinaryNode(
    super.parent,
    super.data,
    Rect attr,
    this.layoutNode, {
    super.value,
    super.id,
  }) {
    this.attr = attr;
  }

  @override
  bool contains(Offset offset) => false;

  @override
  void onDraw(CCanvas canvas, Paint paint) {}

  @override
  void updateStyle(Context context, covariant ChartSeries series) {}
}
