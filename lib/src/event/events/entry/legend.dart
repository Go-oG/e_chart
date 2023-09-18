import 'package:e_chart/e_chart.dart';

class LegendSelectedEvent extends ChartEvent {
  final LegendItem legendItem;

  LegendSelectedEvent(this.legendItem);
}

class LegendUnSelectedEvent extends ChartEvent {
  final LegendItem legendItem;

  LegendUnSelectedEvent(this.legendItem);
}

class LegendSelectChangeEvent extends ChartEvent {
  final LegendToggleSelectAction action;

  LegendSelectChangeEvent(this.action);
}

class LegendScrollEvent extends ChartEvent {
  final LegendScrollAction action;

  LegendScrollEvent(this.action);
}
