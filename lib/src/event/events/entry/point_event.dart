import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class UserClickEvent extends ChartEvent {
  final EventInfo event;
  Offset localOffset;
  Offset globalOffset;

  UserClickEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
  @override
  EventType get eventType => EventType.click;
}

class UserDoubleClickEvent extends ChartEvent {
  final Offset localOffset;
  final Offset globalOffset;
  final EventInfo event;

  UserDoubleClickEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
  @override
  EventType get eventType => EventType.doubleClick;
}

class UserHoverEvent extends ChartEvent {
  Offset localOffset;
  Offset globalOffset;
  final EventInfo event;

  UserHoverEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
  @override
  EventType get eventType => EventType.hover;
}

class UserHoverEndEvent extends ChartEvent {
  final EventInfo event;

  UserHoverEndEvent(this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
  @override
  EventType get eventType => EventType.hover;
}

class UserLongPressEvent extends ChartEvent {
  Offset localOffset;
  Offset globalOffset;
  final EventInfo event;

  UserLongPressEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }
  @override
  EventType get eventType => EventType.longPress;
}

class UserLongPressEndEvent extends ChartEvent {
  final EventInfo event;
  UserLongPressEndEvent(this.event);
  @override
  String toString() {
    return "$runtimeType:$event";
  }
  @override
  EventType get eventType => EventType.longPress;

}

