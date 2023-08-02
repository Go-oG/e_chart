import 'dart:ui';

import 'package:e_chart/e_chart.dart';

class GraphEvent extends ChartEvent {
  final String? seriesId;
  final int? seriesIndex;
  final num zoom;
  final Offset center;

  GraphEvent(
    this.zoom,
    this.center, {
    this.seriesIndex,
    this.seriesId,
  }) {
    if (seriesIndex == null || seriesId == null) {
      throw ChartError("seriesIndex 和 seriesId不能同时为空");
    }
  }
}
