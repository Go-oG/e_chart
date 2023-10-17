import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class AxisShowRangeChangeEvent extends ChartEvent {
  final String coordId;
  final String coordViewId;
  final CoordType coordType;
  final String axisId;
  final String axisViewId;
  final BaseScale scale;
  final List<dynamic> showRangeData;

  const AxisShowRangeChangeEvent(
    this.coordId,
    this.coordViewId,
    this.coordType,
    this.axisId,
    this.axisViewId,
    this.scale,
    this.showRangeData,
  );

  @override
  EventType get eventType => EventType.axisShowRangeChange;
}

class AxisRangeChangeEvent extends ChartEvent {
  final String coordId;
  final String coordViewId;
  final CoordType coordType;
  final String axisId;
  final String axisViewId;
  final BaseScale scale;
  final List<dynamic> showRangeData;

  const AxisRangeChangeEvent(
    this.coordId,
    this.coordViewId,
    this.coordType,
    this.axisId,
    this.axisViewId,
    this.scale,
    this.showRangeData,
  );

  @override
  EventType get eventType => EventType.axisRangeChange;
}

class AxisLabelClickEvent extends ChartEvent {
  final String coordId;
  final String coordViewId;
  final CoordType coordType;
  final String axisId;
  final String axisViewId;
  final BaseScale scale;
  dynamic label;
  Offset offset;

  AxisLabelClickEvent(
    this.coordId,
    this.coordViewId,
    this.coordType,
    this.axisId,
    this.axisViewId,
    this.scale,
    this.label,
    this.offset,
  );

  @override
  EventType get eventType => EventType.axisLabelClick;
}
