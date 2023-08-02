import '../chart_event.dart';

class ClickEvent extends ChartEvent {
  final EventParams event;

  ClickEvent(this.event);
}

class DoubleClickEvent extends ChartEvent {
  final EventParams event;

  DoubleClickEvent(this.event);
}

class HoverInEvent extends ChartEvent {
  final EventParams event;

  HoverInEvent(this.event);
}

class HoverOutEvent extends ChartEvent {
  final EventParams event;

  HoverOutEvent(this.event);
}

class HoverStartEvent extends ChartEvent {
  HoverStartEvent();
}

class HoverUpdateEvent extends ChartEvent {
  HoverUpdateEvent();
}

class HoverEndEvent extends ChartEvent {
  HoverEndEvent();
}

class LongPressEvent extends ChartEvent {
  final EventParams event;

  LongPressEvent(this.event);
}

class ScrollEvent extends ChartEvent {}
