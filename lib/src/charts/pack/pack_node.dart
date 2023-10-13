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
  void onDraw(CCanvas canvas, Paint paint) {
    var style = itemStyle;
    var bs = borderStyle;
    if (style.notDraw && bs.notDraw) {
      return;
    }
    bool ds = false;
    if (scale != 1) {
      ds = true;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale);
      canvas.translate(-center.dx, -center.dy);
    }
    style.drawCircle(canvas, paint, center, r);
    bs.drawCircle(canvas, paint, center, r);
    if (ds) {
      canvas.restore();
    }
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
    label.style = series.getLabelStyle(context, this) ?? LabelStyle.empty;
    label.updatePainter();
  }

}
