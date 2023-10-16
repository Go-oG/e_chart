import 'package:e_chart/e_chart.dart';

class RenderedEvent extends ChartEvent {
  static const RenderedEvent rendered = RenderedEvent();

  const RenderedEvent();

  @override
  EventType get eventType => EventType.rendered;
}
