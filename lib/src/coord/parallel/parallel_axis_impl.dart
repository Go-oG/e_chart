import 'dart:math';
import 'dart:ui';

import '../../component/axis/impl/line_axis_impl.dart';
import '../../model/dynamic_data.dart';
import '../../model/enums/direction.dart';
import 'parallel_axis.dart';

class ParallelAxisImpl extends LineAxisImpl<ParallelAxis, LineProps> {
  final Direction direction;

  ParallelAxisImpl(
    super.axis,
    this.direction,
    int index,
  ) : super(index: index);

  List<Offset> dataToPosition(DynamicData data) {
    double diffY = props.end.dy - props.start.dy;
    double diffX = props.end.dx - props.start.dx;
    List<num> nl = scale.toRange(data.data);
    List<Offset> ol = [];
    for (var d in nl) {
      double at = atan2(diffY, diffX);
      double x = props.start.dx + d * cos(at);
      double y = props.start.dy + d * sin(at);
      ol.add(Offset(x, y));
    }
    return ol;
  }
}
