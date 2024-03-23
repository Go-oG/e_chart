import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/heatmap/heat_map_helper.dart';
import 'package:flutter/material.dart';

/// 热力图
class HeatMapView extends CoordChildView<HeatMapSeries, HeatMapHelper> {
  HeatMapView(super.context, super.series);

  @override
  HeatMapHelper buildLayoutHelper(var oldHelper) {
    oldHelper?.dispose();
    return HeatMapHelper(context, this, series);
  }

  @override
  void onDraw(CCanvas canvas) {
    var sRect = selfViewPort;
    each(layoutHelper.dataSet, (node, index) {
      Rect rect = node.attr;
      if (!rect.overlaps(sRect)) {
        return;
      }
      node.onDraw(canvas, mPaint);
    });
  }

  @override
  bool get enableDrag => true;

  @override
  CoordInfo getEmbedCoord() => const CoordInfo(CoordType.calendar, 0);

  @override
  int getAxisDataCount(CoordType type, AxisDim dim) {
    if (type != CoordType.calendar) {
      return -1;
    }
    return series.data.length;
  }

  @override
  DynamicText getAxisMaxText(CoordType type, AxisDim axisDim) {
    return DynamicText.empty;
  }

  @override
  Iterable getAxisExtreme(CoordType type, AxisDim axisDim) {
    if (type != CoordType.calendar) {
      return List.empty();
    }
    List<dynamic> dl = [];
    for (var element in series.data) {
      dl.add(element.x);
    }
    return dl;
  }

  @override
  dynamic getDimData(CoordType type, AxisDim dim, data) {
    if (type.isCalendar()) {
      return (data as HeatMapData).x;
    }
    return null;
  }
}
