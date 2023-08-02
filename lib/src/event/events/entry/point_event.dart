import '../chart_event.dart';

class ClickEvent extends ChartEvent {
  final EventParams event;

  ClickEvent(this.event);
}

class DoubleClickEvent extends ChartEvent {
  final EventParams event;

  DoubleClickEvent(this.event);
}

class HoverStartEvent extends ChartEvent {
  final EventParams event;

  HoverStartEvent(this.event);
}

class HoverUpdateEvent extends ChartEvent {
  final EventParams event;

  HoverUpdateEvent(this.event);
}

class HoverEndEvent extends ChartEvent {
  final EventParams event;

  HoverEndEvent(this.event);
}

class LongPressEvent extends ChartEvent {
  final EventParams event;
  LongPressEvent(this.event);
}

class ScrollEvent extends ChartEvent{}
