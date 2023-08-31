import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class PackNode extends TreeNode<TreeData, Rect, PackNode> {
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
    style.drawCircle(canvas, paint, center, r);
    bs.drawArc(canvas, paint, r - bs.width / 2, 0, 360);
  }

  @override
  bool contains(Offset offset) {
    return offset.inCircle(r * scale, center: center);
  }

  double get r => size.width / 2;

  set r(num radius) => size = Size.square(radius * 2);

  @override
  void updateStyle(Context context, covariant PackSeries series) {
    itemStyle = series.getItemStyle(context, this) ?? AreaStyle.empty;
    borderStyle = series.getBorderStyle(context, this) ?? LineStyle.empty;
    labelStyle = series.getLabelStyle(context, this) ?? LabelStyle.empty;
  }
}
