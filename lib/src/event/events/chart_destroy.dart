import 'package:e_chart/src/event/chart_event_dispatcher.dart';

import '../chart_event.dart';

class ChartDestroyEvent extends ChartEvent {
  static const single = ChartDestroyEvent();

  const ChartDestroyEvent();

  @override
  EventType get eventType => EventType.chartDestroy;
}
