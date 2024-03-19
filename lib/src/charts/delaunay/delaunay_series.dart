import 'package:e_chart/e_chart.dart';

import 'delaunay_view.dart';

class DelaunaySeries extends ChartSeries {
  List<ChartOffset> data;
  bool triangle;
  Fun2<DelaunayData, AreaStyle?>? areaStyleFun;
  Fun2<DelaunayData, LineStyle?>? borderFun;

  DelaunaySeries(
    this.data, {
    this.triangle = true,
    this.areaStyleFun,
    this.borderFun,
    super.animation,
    super.backgroundColor,
    super.clip,
    super.layoutParams,
    super.id,
    super.name,
    super.useSingleLayer,
    super.tooltip,
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
  ChartView? toView(Context context) {
    return DelaunayView(context, this);
  }

  @override
  SeriesType get seriesType => SeriesType.delaunay;

  AreaStyle getAreaStyle(Context context, DelaunayData data) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data) ?? AreaStyle.empty;
    }
    return context.option.theme.getAreaStyle(data.dataIndex).convert(data.status);
  }

  LineStyle getBorderStyle(Context context, DelaunayData data) {
    if (borderFun != null) {
      return borderFun?.call(data) ?? LineStyle.empty;
    }
    return LineStyle.empty;
  }
}
