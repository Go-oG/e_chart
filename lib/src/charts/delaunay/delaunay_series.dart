import 'dart:ui';

import 'package:e_chart/e_chart.dart';

import 'delaunay_view.dart';

class DelaunaySeries extends RectSeries {
  List<ChartOffset> data;
  bool triangle;
  Fun3<DShape, Set<ViewState>, AreaStyle?>? areaStyleFun;
  Fun3<DShape, Set<ViewState>, LineStyle?>? borderFun;

  DelaunaySeries(
    this.data, {
    this.triangle = true,
    this.areaStyleFun,
    this.borderFun,
  });

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
    return DelaunayView(this);
  }

  final SeriesType _type = const SeriesType("delaunay");

  @override
  SeriesType get seriesType => _type;

  AreaStyle getAreaStyle(Context context, DShape data, int dataIndex, Set<ViewState> status) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, status)??AreaStyle.empty;
    }
    return context.option.theme.getAreaStyle(dataIndex).convert(status);
  }

  LineStyle getBorderStyle(Context context, DShape data, int dataIndex, Set<ViewState> status) {
    if (borderFun != null) {
      return borderFun?.call(data, status) ?? LineStyle.empty;
    }
    return LineStyle.empty;
  }
}
