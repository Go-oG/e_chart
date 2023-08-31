import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class TreeLayoutNode extends TreeNode<TreeData, TreeAttr, TreeLayoutNode> {
  TreeLayoutNode(
    super.parent,
    super.data,
    super.dataIndex,
    super.attr,
    super.itemStyle,
    super.borderStyle,
    super.labelStyle, {
    super.deep,
    super.maxDeep,
    super.value,
  });

  @override
  String toString() {
    return '$data x:${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}';
  }

  @override
  bool contains(Offset offset) {
    return attr.symbol.internal2(center, size, offset);
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    Offset offset = center;
    if (offset.dx.isNaN || offset.dy.isNaN) {
      return;
    }
    attr.symbol.draw(canvas, paint, offset);
    var lb = label;
    var ls = labelStyle;
    var config = labelConfig;
    if (lb == null || lb.isEmpty || !ls.show || config == null) {
      return;
    }
    ls.draw(canvas, paint, lb, config);
  }

  @override
  void updateStyle(Context context, covariant TreeSeries series) {

  }
}

class TreeAttr {
  ChartSymbol symbol;

  TreeAttr(this.symbol);

  TreeAttr.of() : symbol = EmptySymbol();
}
