import 'dart:ui';

import '../../component/axis/line/line_attrs.dart';
import '../../component/axis/line/line_axis_impl.dart';
import '../../core/render/ccanvas.dart';
import 'radar_axis.dart';

class RadarAxisImpl extends LineAxisImpl<RadarAxis, LineAxisAttrs> {
  RadarAxisImpl(super.context, super.axis, super.attrs);

  double dataToRadius(num data) {
    return scale.toRange(data)[0].toDouble();
  }

  @override
  void onDrawAxisTick(CCanvas canvas, Paint paint) {}

  @override
  void onDrawAxisLabel(CCanvas canvas, Paint paint) {}
}
