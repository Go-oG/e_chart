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
  }) {
    label.text = data.name ?? DynamicText.empty;
  }

  @override
  String toString() {
    return '$data x:${x.toStringAsFixed(2)} y:${y.toStringAsFixed(2)}';
  }

  @override
  bool contains(Offset offset) {
    return attr.symbol.contains(center, offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    Offset offset = center;
    if (offset.dx.isNaN || offset.dy.isNaN) {
      return;
    }
    attr.symbol.draw(canvas, paint, offset);
    label.draw(canvas, paint);
  }

  @override
  void updateStyle(Context context, covariant TreeSeries series) {
    label.updatePainter(style: series.getLabelStyle(context, this));
  }
}

class TreeAttr {
  ChartSymbol symbol;

  TreeAttr(this.symbol);

  TreeAttr.of() : symbol = EmptySymbol();
}
