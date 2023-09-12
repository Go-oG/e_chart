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
}

class UserHoverEndEvent extends ChartEvent {
  final EventInfo event;

  UserHoverEndEvent(this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
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
}

class UserLongPressEndEvent extends ChartEvent {
  final EventInfo event;
  UserLongPressEndEvent(this.event);
  @override
  String toString() {
    return "$runtimeType:$event";
  }

}

class UserScrollEvent extends ChartEvent {
  Offset scroll;
  final CoordType? coordSystem;
  final String coordId;

  UserScrollEvent(
    this.coordId,
    this.scroll, {
    this.coordSystem,
  });
}
