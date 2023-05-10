import 'dart:math';
import 'dart:ui';

import '../../component/axis/impl/line_axis_impl.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/direction.dart';
import 'parallel_axis.dart';

class ParallelAxisImpl extends LineAxisImpl<ParallelAxis> {
  final Direction direction;

  ParallelAxisImpl(
    super.axis,
    this.direction,
    int index,
  ) : super(index: index);

  Offset dataToPoint(DynamicData data) {
    double xy = scale.rangeValue(data).toDouble();
    double at = atan2(props.end.dy - props.start.dy, props.end.dx - props.start.dx);
    double x = props.start.dx + xy * cos(at);
    double y = props.start.dy + xy * sin(at);
    return Offset(x, y);
  }
}
