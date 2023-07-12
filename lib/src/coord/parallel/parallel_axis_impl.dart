import 'dart:math';
import 'dart:ui';

import '../../component/axis/impl/line_axis_impl.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/direction.dart';
import 'parallel_axis.dart';

class ParallelAxisImpl extends LineAxisImpl<ParallelAxis, LineProps> {
  final Direction direction;

  ParallelAxisImpl(super.axis, this.direction, {super.axisIndex});


  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Rect coord) {}

  @override
  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Rect coord) {}
}
