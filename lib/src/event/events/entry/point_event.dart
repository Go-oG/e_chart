import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class ClickEvent extends ChartEvent {
  final EventInfo event;
  Offset localOffset;
  Offset globalOffset;

  ClickEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
}

class DoubleClickEvent extends ChartEvent {
  final Offset localOffset;
  final Offset globalOffset;
  final EventInfo event;

  DoubleClickEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
}

class HoverEvent extends ChartEvent {
  Offset localOffset;
  Offset globalOffset;
  final EventInfo event;

  HoverEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
}

class HoverEndEvent extends ChartEvent {
  final EventInfo event;

  HoverEndEvent(this.event);

  @override
  String toString() {
    return "$runtimeType\n$event";
  }
}

class LongPressEvent extends ChartEvent {
  Offset localOffset;
  Offset globalOffset;
  final EventInfo event;

  LongPressEvent(this.localOffset, this.globalOffset, this.event);

  @override
  String toString() {
    return "$runtimeType:$event";
  }
}

class LongPressEndEvent extends ChartEvent {
  final EventInfo event;
  LongPressEndEvent(this.event);
  @override
  String toString() {
    return "$runtimeType:$event";
  }

}

class ScrollEvent extends ChartEvent {
  Offset scroll;
  final CoordType? coordSystem;
  final String coordId;

  ScrollEvent(
    this.coordId,
    this.scroll, {
    this.coordSystem,
  });
}
