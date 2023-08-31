import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PackNode extends TreeNode<TreeData, PackAttr, PackNode> {
  PackNode(
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
    super.groupIndex,
  });


  @override
  void onDraw(Canvas canvas, Paint paint) {
    var style = itemStyle;
    var bs = borderStyle;
    if (style.notDraw && bs.notDraw) {
      return;
    }
    Offset center = attr.center();
    double r = attr.r;
    style.drawCircle(canvas, paint, center, r);
    bs.drawArc(canvas, paint, r - bs.width / 2, 0, 360);
  }

  @override
  bool contains(Offset offset) {
    return offset.inCircle(attr.r * attr.scale, center: center);
  }
}

class PackAttr {
  double x;
  double y;
  double r;
  double scale = 1;

  PackAttr(this.x, this.y, this.r);

  Offset center() => Offset(x, y);

  @override
  String toString() {
    return '[x:${x.toStringAsFixed(2)},y:${y.toStringAsFixed(2)},r:${r.toStringAsFixed(2)}]';
  }
}
