import 'package:e_chart/e_chart.dart';

import 'point_view.dart';

class PointSeries extends RectSeries {
  List<PointGroup> data;
  Fun4<PointData, PointGroup, Set<ViewState>,  ChartSymbol>? symbolFun;

  PointSeries(
    this.data, {
    this.symbolFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.gridIndex,
    super.polarIndex = 0,
    super.calendarIndex = 0,
    super.coordType = CoordType.grid,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
  }) : super(radarIndex: -1, parallelIndex: -1);

  @override
  ChartView? toView() {
    return PointView(this);
  }

  ChartSymbol getSymbol(
      Context context, PointData data, int index, PointGroup group,  Set<ViewState> status) {
    var fun = symbolFun;
    if (fun != null) {
      return fun.call(data, group, status);
    }

    return CircleSymbol(
      radius: 10,
      itemStyle: AreaStyle(color: context.option.theme.getColor(index)).convert(status),
    );
  }

  @override
  List<LegendItem> getLegendItem(Context context) =>[];

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex=p1+start;
    });
    return data.length;
  }
}
