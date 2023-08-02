import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class BrushAction extends ChartAction {
  final List<BrushActionData> actionList;

  BrushAction(this.actionList);
}

class BrushEndAction extends ChartAction {
  final List<BrushActionData> actionList;

  BrushEndAction(this.actionList);
}

class BrushClearAction extends ChartAction {}

class BrushActionData {
  final CoordSystem coord;
  final int? xAxisIndex;
  final int? yAxisIndex;
  final BrushType brushType;
  final List<num> range;
  final List<Offset> coordRange;

  BrushActionData(
    this.coord, {
    this.xAxisIndex,
    this.yAxisIndex,
    this.brushType = BrushType.rect,
    this.range = const [],
    this.coordRange = const [],
  });
}
