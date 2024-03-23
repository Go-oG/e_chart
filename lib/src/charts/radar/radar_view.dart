import 'dart:math';

import 'package:e_chart/e_chart.dart';
import 'radar_helper.dart';

/// 雷达图
class RadarView extends CoordChildView<RadarSeries, RadarHelper> {
  RadarView(super.context, super.series);

  @override
  RadarHelper buildLayoutHelper(var oldHelper) {
    if (oldHelper != null) {
      oldHelper.context = context;
      oldHelper.view = this;
      oldHelper.series = series;
      return oldHelper;
    }
    return RadarHelper(context, this, series);
  }

  @override
  void onDraw(CCanvas canvas) {
    var nodeList = layoutHelper.dataList;
    each(nodeList, (group, i) {
      group.onDraw(canvas, mPaint);
    });
  }

  @override
  CoordInfo getEmbedCoord() => CoordInfo(CoordType.radar, max(0, series.radarIndex));

  @override
  int getAxisDataCount(CoordType type, AxisDim dim) {
    if (!type.isRadar()) {
      return 0;
    }
    return series.data.length;
  }

  @override
  DynamicText getAxisMaxText(CoordType type, AxisDim axisDim) => DynamicText.empty;

  @override
  dynamic getDimData(CoordType type, AxisDim dim, data) => null;

  @override
  Iterable getAxisExtreme(CoordType type, AxisDim axisDim) {
    if (!type.isRadar()) {
      return [];
    }
    List<num> resultList = [];
    for (var group in series.data) {
      if (group.data.length > axisDim.index) {
        resultList.add(group.data[axisDim.index].value);
      }
    }
    return resultList;
  }

}
