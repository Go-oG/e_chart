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

class UserHoverStartEvent extends ChartEvent {
  final EventInfo event;
  Offset localOffset;
  Offset globalOffset;
  UserHoverStartEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }

  @override
  EventType get eventType => EventType.hoverStart;
}

class UserHoverUpdateEvent extends ChartEvent {
  Offset localOffset;
  Offset globalOffset;
  final EventInfo event;

  UserHoverUpdateEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }

  @override
  EventType get eventType => EventType.hoverUpdate;
}

class UserHoverEndEvent extends ChartEvent {
  final EventInfo event;

  UserHoverEndEvent(this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }

  @override
  EventType get eventType => EventType.hoverEnd;
}

class UserLongPressUpdateEvent extends ChartEvent {
  final EventInfo event;
  Offset localOffset;
  Offset globalOffset;

  UserLongPressUpdateEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }

  @override
  EventType get eventType => EventType.longPressUpdate;
}

class UserLongPressEndEvent extends ChartEvent {
  final EventInfo event;

  UserLongPressEndEvent(this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }

  @override
  EventType get eventType => EventType.longPressEnd;
}

class UserLongPressStartEvent extends ChartEvent {
  final EventInfo event;

  UserLongPressStartEvent(this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }

  @override
  EventType get eventType => EventType.longPressStart;
}

class UserDragStartEvent extends ChartEvent {
  @override
  EventType get eventType => EventType.dragStart;
}

class UserDragUpdateEvent extends ChartEvent {
  @override
  EventType get eventType => EventType.dragUpdate;
}

class UserDragEndEvent extends ChartEvent {
  @override
  EventType get eventType => EventType.dragEnd;
}
