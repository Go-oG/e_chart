import 'package:flutter/material.dart';
import 'package:xchart/src/charts/point/point_series.dart';
import 'package:xchart/src/core/view.dart';

import '../../coord/polar/polar_child.dart';
import '../../coord/polar/polar_layout.dart';
import '../../model/dynamic_data.dart';

class PointView extends View with PolarChild {
  final PointSeries series;

  PointView(this.series);

  @override
  List<DynamicData> get angleDataSet {
    List<DynamicData> dl = [];
    for (var ele in series.data) {
      dl.add(ele.y);
    }
    return dl;
  }

  @override
  List<DynamicData> get radiusDataSet {
    List<DynamicData> dl = [];
    for (var ele in series.data) {
      dl.add(ele.x);
    }
    return dl;
  }

  @override
  void onDraw(Canvas canvas) {
    PolarLayout layout = context.findPolarCoord();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    paint.color = Colors.blue;
    Path path = Path();
    bool hasMOve = false;
    for (var ele in series.data) {
      Offset offset = layout.dataToPoint(ele.y, ele.x);
      if (!hasMOve) {
        path.moveTo(offset.dx, offset.dy);
        hasMOve = true;
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    canvas.save();
    canvas.translate(width / 2, height / 2);
    canvas.drawPath(path, paint);
    canvas.restore();
  }
}
