import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ClickEvent extends ChartEvent {
  final Offset localOffset;
  final Offset globalOffset;
  final EventParams event;

  ClickEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
}

class DoubleClickEvent extends ChartEvent {
  final Offset localOffset;
  final Offset globalOffset;
  final EventParams event;

  DoubleClickEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
}

class HoverInEvent extends ChartEvent {
  final Offset localOffset;
  final Offset globalOffset;
  final EventParams event;

  HoverInEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
}

class HoverOutEvent extends ChartEvent {
  final EventParams event;

  HoverOutEvent(this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
}

class HoverStartEvent extends ChartEvent {
  final Offset localOffset;
  final Offset globalOffset;
  final EventParams event;

  HoverStartEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event\nLO:$localOffset\nGO:$globalOffset";
  }
}

class HoverUpdateEvent extends ChartEvent {
  final Offset localOffset;
  final Offset globalOffset;
  final EventParams event;

  HoverUpdateEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType:$event LO:$localOffset GO:$globalOffset";
  }
}

class HoverEndEvent extends ChartEvent {
  final EventParams event;

  HoverEndEvent(this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }
}

class LongPressEvent extends ChartEvent {
  final Offset localOffset;
  final Offset globalOffset;
  final EventParams event;

  LongPressEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }
}

class ScrollEvent extends ChartEvent {
  final Offset scroll;
  final CoordType? coordSystem;
  final String coordId;

  ScrollEvent(
    this.coordId,
    this.scroll, {
    this.coordSystem,
  });
}
