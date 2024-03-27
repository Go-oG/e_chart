import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class AxisLineDrawable extends Drawable {
  List<dynamic> data;
  int index;
  int maxIndex;
  Offset start;
  Offset end;
  Path? path;
  LineStyle style;

  AxisLineDrawable(this.data, this.index, this.maxIndex, this.start, this.end, this.style);

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

class AxisCurveDrawable extends Drawable {
  late List<dynamic> data;
  int index;
  int maxIndex;
  Offset center;
  num radius;
  num startAngle;
  num sweepAngle;
  LineStyle style;

  AxisCurveDrawable(
    dynamic data,
    this.index,
    this.maxIndex,
    this.center,
    this.radius,
    this.startAngle,
    this.sweepAngle,
    this.style,
  ) {
    if (data is List<dynamic>) {
      this.data = data;
    } else {
      this.data = [data];
    }
  }

  @override
  void draw(CCanvas canvas, Paint paint) {
    style.drawArc(canvas, paint, radius, startAngle, sweepAngle, center);
  }
}
