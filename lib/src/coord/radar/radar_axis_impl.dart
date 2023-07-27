import 'dart:ui';

import '../../component/axis/line/line_attrs.dart';
import '../../component/axis/line/line_axis_impl.dart';
import 'radar_axis.dart';
import 'radar_coord.dart';

class RadarAxisImpl extends LineAxisImpl<RadarAxis, LineAxisAttrs, RadarCoord> {
  RadarAxisImpl(super.context, super.coord, super.axis, {super.axisIndex});

  double dataToRadius(num data) {
    return scale.toRange(data)[0].toDouble();
  }

  @override
  void onDrawAxisTick(Canvas canvas, Paint paint, Offset scroll) {}

  @override
  void onDrawAxisLabel(Canvas canvas, Paint paint, Offset scroll) {}
}
