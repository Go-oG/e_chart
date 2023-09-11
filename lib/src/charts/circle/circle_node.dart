import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CircleNode extends DataNode<Arc, CircleItemData> {
  AreaStyle backgroundStyle = AreaStyle.empty;
  Arc backgroundArc = Arc();

  CircleNode(
      super.data, super.dataIndex, super.groupIndex, super.attr, super.itemStyle, super.borderStyle, super.labelStyle);

  @override
  bool contains(Offset offset) {
    return attr.contains(offset);
  }

  @override
  void onDraw(Canvas canvas, Paint paint) {
    backgroundStyle.drawArc(canvas, paint, backgroundArc,true);
    itemStyle.drawArc(canvas, paint, attr,true);
    borderStyle.drawPath(canvas, paint, attr.toPath());
  }

  @override
  set attr(Arc a) {
    super.attr = a;
    int dir = a.sweepAngle < 0 ? -1 : 1;
    backgroundArc = a.copy(sweepAngle: 360 * dir);
  }

  @override
  void updateStyle(Context context, covariant CircleSeries series) {
    itemStyle = series.getAreaStyle(context, data, dataIndex, status);
    borderStyle = series.getBorderStyle(context, data, dataIndex, status);
    labelStyle = series.getLabelStyle(context, data, dataIndex, status);
  }
}
