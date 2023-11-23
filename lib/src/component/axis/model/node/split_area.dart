import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class SplitAreaNode {
  List<dynamic> data;
  Path path;
  AreaStyle style;

  SplitAreaNode(this.data, this.path, this.style);

  void draw(CCanvas canvas, Paint paint) {
    style.drawPath(canvas, paint, path);
  }
}

class CurveSplitLineNode extends Disposable {
  List<dynamic> data;
  int index;
  int maxIndex;
  Offset center;
  num innerRadius;
  num outRadius;
  num angle;
  LineStyle style;

  CurveSplitLineNode(
    this.data,
    this.index,
    this.maxIndex,
    this.center,
    this.innerRadius,
    this.outRadius,
    this.angle,
    this.style,
  );

  void draw(CCanvas canvas, Paint paint) {
    style.drawLine(
      canvas,
      paint,
      circlePoint(innerRadius, angle, center),
      circlePoint(outRadius, angle, center),
    );
  }
}
