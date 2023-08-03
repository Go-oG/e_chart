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

class BrushClearAction extends ChartAction {
  final String brushId;
  BrushClearAction(this.brushId);
}

class BrushActionData {
  final String brushId;
  final int? xAxisIndex;
  final int? yAxisIndex;
  final BrushType brushType;
  ///存储选框的范围点
  final List<Offset> range;

  BrushActionData(
    this.brushId, {
    this.xAxisIndex,
    this.yAxisIndex,
    this.brushType = BrushType.rect,
    this.range = const [],
  });
}
