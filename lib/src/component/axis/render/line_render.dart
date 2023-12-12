import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/core/render/element_render.dart';

class AxisLineRender extends ElementRender {
  List<dynamic> data;
  int index;
  int maxIndex;
  Offset start;
  Offset end;
  Path? path;
  LineStyle style;

  AxisLineRender(this.data, this.index, this.maxIndex, this.start, this.end, this.style);

  @override
  void draw(CCanvas canvas, Paint paint) {
    var p = path;
    if (p != null) {
      style.drawPath(canvas, paint, p, drawDash: false);
    } else {
      style.drawLine(canvas, paint, start, end);
    }
  }
}

class AxisCurveRender extends ElementRender {
  List<dynamic> data;
  int index;
  int maxIndex;
  Offset center;
  num radius;
  num startAngle;
  num sweepAngle;
  LineStyle style;

  AxisCurveRender(
    this.data,
    this.index,
    this.maxIndex,
    this.center,
    this.radius,
    this.startAngle,
    this.sweepAngle,
    this.style,
  );

  @override
  void draw(CCanvas canvas, Paint paint) {
    style.drawArc(canvas, paint, radius, startAngle, sweepAngle, center);
  }
}
