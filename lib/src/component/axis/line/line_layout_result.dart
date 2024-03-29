import 'dart:ui';

import '../model/axis_layout_result.dart';
import 'line_split_area.dart';

class LineAxisLayoutResult extends AxisLayoutResult {
  final num viewSize;
  ///存储当前坐标轴的起点和终点(不一定等于视图宽高)
  final Offset start;
  final Offset end;

  final List<LineSplitResult> split;

  LineAxisLayoutResult(
    this.viewSize,
    this.start,
    this.end,
    this.split,
    super.tick,
    super.label,
  );
}
