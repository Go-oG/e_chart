import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class CircleData extends RenderData<Arc> {
  num value;
  num max;
  num offsetAngle;

  ///Attr
  AreaStyle backgroundStyle = AreaStyle.empty;
  Arc backgroundArc = Arc.zero;

  CircleData(
    this.value,
    this.max, {
    this.offsetAngle = 0,
  }) {
    attr = Arc.zero;
  }

  @override
  bool contains(Offset offset) {
    return attr.contains(offset);
  }

  @override
  void onDraw(CCanvas canvas, Paint paint) {
    backgroundStyle.drawArc(canvas, paint, backgroundArc, true);
    itemStyle.drawArc(canvas, paint, attr, true);
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
    itemStyle = series.getItemStyle(context, this);
    borderStyle = series.getBorderStyle(context, this);
    label.style = series.getLabelStyle(context, this);
  }
}
