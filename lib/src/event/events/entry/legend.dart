import 'package:e_chart/e_chart.dart';

class LegendSelectedEvent extends ChartEvent {
  final LegendSelectAction action;
  LegendSelectedEvent(this.action);
}

class LegendUnSelectedEvent extends ChartEvent {
  final LegendUnSelectAction action;
  LegendUnSelectedEvent(this.action);
}

class LegendSelectChangeEvent extends ChartEvent {
  final LegendToggleSelectAction action;

  LegendSelectChangeEvent(this.action);
}

class LegendScrollEvent extends ChartEvent {
  final LegendScrollAction action;
  LegendScrollEvent(this.action);
}
