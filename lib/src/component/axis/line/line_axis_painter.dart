import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class LineAxisPainter extends AxisPainter {
  final num viewSize;
  ///存储当前坐标轴的起点和终点(不一定等于视图宽高)
  final Offset start;
  final Offset end;
  final List<LineSplitResult> split;

  LineAxisPainter(
    this.viewSize,
    this.start,
    this.end,
    this.split,
    super.line,
    super.tick,
    super.label,
  );

  @override
  void dispose() {
    split.clear();
    super.dispose();
  }
}
