import 'package:e_chart/e_chart.dart';

class BrushEvent extends ChartEvent {
  final CoordSystem coord;
  final String brushId;
  final int? xAxisIndex;
  final int? yAxisIndex;
  final List<BrushArea> data;

  BrushEvent(
    this.coord,
    this.brushId, {
    this.xAxisIndex,
    this.yAxisIndex,
    this.data = const [],
  });
}

class BrushEndEvent extends ChartEvent {
  final CoordSystem coord;
  final String brushId;
  final List<BrushArea> data;

  BrushEndEvent(this.coord, this.brushId, this.data);
}

class BrushClearEvent extends ChartEvent {
  final String brushId;
  final CoordSystem coord;

  BrushClearEvent(this.brushId, this.coord);
}
