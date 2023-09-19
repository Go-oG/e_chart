import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class TreeEvent extends ChartEvent {
  final String? seriesId;
  final int? seriesIndex;
  final num zoom;
  final Offset offset;

  TreeEvent(
    this.zoom,
    this.offset, {
    this.seriesId,
    this.seriesIndex,
  }) {
    if (seriesIndex == null || seriesId == null) {
      throw ChartError("seriesIndex 和 seriesId不能同时为空");
    }
  }
  @override
  EventType get eventType => EventType.normal;
}
