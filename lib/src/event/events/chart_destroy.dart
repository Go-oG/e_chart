import 'package:e_chart/src/event/chart_event_dispatcher.dart';

import '../chart_event.dart';

class ChartDisposeEvent extends ChartEvent {
  static const single = ChartDisposeEvent();

  const ChartDisposeEvent();

  @override
  EventType get eventType => EventType.chartDispose;
}
