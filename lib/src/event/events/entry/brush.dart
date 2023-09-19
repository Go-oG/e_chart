import 'package:e_chart/e_chart.dart';

class BrushEvent extends ChartEvent {
  final CoordType coord;
  final String brushId;
  final int? xAxisIndex;
  final int? yAxisIndex;
  final List<BrushArea> data;

  BrushEvent(this.coord,
      this.brushId, {
        this.xAxisIndex,
        this.yAxisIndex,
        this.data = const [],
      });

  @override
  EventType get eventType => EventType.brush;
}

class BrushEndEvent extends ChartEvent {
  final CoordType coord;
  final String brushId;
  final List<BrushArea> data;

  BrushEndEvent(this.coord, this.brushId, this.data);

  @override
  EventType get eventType => EventType.brush;
}

class BrushClearEvent extends ChartEvent {
  final String brushId;
  final CoordType coord;

  BrushClearEvent(this.brushId, this.coord);

  @override
  EventType get eventType => EventType.brush;
}
