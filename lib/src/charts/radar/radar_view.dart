import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';
import 'radar_helper.dart';

/// 雷达图
class RadarView extends SeriesView<RadarSeries, RadarHelper> implements RadarChild {
  RadarView(super.series);

  @override
  void onDraw(Canvas canvas) {
    var nodeList = layoutHelper.groupNodeList;
    each(nodeList, (group, i) {
      group.onDraw(canvas, mPaint);
    });
  }

  @override
  List<num> dataSet(int dim) {
    List<num> resultList = [];
    for (var group in series.data) {
      if (group.data.length > dim) {
        resultList.add(group.data[dim].value);
      }
    }
    return resultList;
  }

  @override
  int get radarIndex => series.radarIndex;

  @override
  RadarHelper buildLayoutHelper() {
    return RadarHelper(context, series);
  }
}
