import 'dart:ui';

import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/delaunator/delaunator_view.dart';

class DelaunatorSeries extends RectSeries {
  List<DelaunatorData> data;

  DelaunatorSeries(this.data);

  @override
  List<LegendItem> getLegendItem(Context context) {
    return [];
  }

  @override
  int onAllocateStyleIndex(int start) {
    return 0;
  }

  @override
  ChartView? toView() {
    return DelaunatorView(this);
  }

  final SeriesType _type = const SeriesType("delaunator");

  @override
  SeriesType get seriesType => _type;
}

class DelaunatorData extends BaseItemData {
  Offset offset;
  dynamic data;

  DelaunatorData(this.offset,{this.data});
}
