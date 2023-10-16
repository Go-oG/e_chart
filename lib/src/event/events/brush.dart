import 'package:e_chart/e_chart.dart';

abstract class BaseBrushEvent extends ChartEvent {
  final String coordId;
  final String coordViewId;
  final CoordType coordType;
  final String brushId;
  List<BrushArea> areas;

  BaseBrushEvent(
    this.coordId,
    this.coordViewId,
    this.coordType,
    this.brushId,
    this.areas,
  );
}

class BrushStartEvent extends BaseBrushEvent {
  BrushStartEvent(super.coordId, super.coordViewId, super.coordType, super.brushId, super.areas);

  @override
  EventType get eventType => EventType.brushStart;
}

class BrushUpdateEvent extends BaseBrushEvent {
  BrushUpdateEvent(super.coordId, super.coordViewId, super.coordType, super.brushId, super.areas);

  @override
  EventType get eventType => EventType.brushUpdate;
}

class BrushEndEvent extends BaseBrushEvent {
  BrushEndEvent(super.coordId, super.coordViewId, super.coordType, super.brushId, super.areas);

  @override
  EventType get eventType => EventType.brushEnd;
}
