import 'package:e_chart/e_chart.dart';

class LegendSelectedEvent extends ChartEvent {
  final LegendItem legendItem;

  LegendSelectedEvent(this.legendItem);

  @override
  EventType get eventType => EventType.legend;
}

class LegendUnSelectedEvent extends ChartEvent {
  final LegendItem legendItem;

  LegendUnSelectedEvent(this.legendItem);

  @override
  EventType get eventType => EventType.legend;
}

class LegendSelectChangeEvent extends ChartEvent {
  final LegendToggleSelectAction action;

  LegendSelectChangeEvent(this.action);

  @override
  EventType get eventType => EventType.legend;
}

class LegendScrollEvent extends ChartEvent {
  final LegendScrollAction action;

  LegendScrollEvent(this.action);

  @override
  EventType get eventType => EventType.legend;
}
