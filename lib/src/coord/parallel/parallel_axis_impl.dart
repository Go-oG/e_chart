import 'dart:ui';

import '../../component/index.dart';
import '../../model/enums/direction.dart';
import 'parallel_axis.dart';

class ParallelAxisImpl extends LineAxisImpl<ParallelAxis, LineAxisAttrs> {
  final Direction direction;

  ParallelAxisImpl(super.context, super.axis, this.direction, {super.axisIndex});

  @override
  void onDrawAxisSplitLine(Canvas canvas, Paint paint, Rect coord) {}

  @override
  void onDrawAxisSplitArea(Canvas canvas, Paint paint, Rect coord) {}
}
