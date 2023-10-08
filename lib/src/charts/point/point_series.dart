import 'package:e_chart/e_chart.dart';

import 'point_view.dart';

class PointSeries extends RectSeries {
  List<PointGroup> data;
  Fun4<PointData, PointGroup, Set<ViewState>, ChartSymbol>? symbolFun;

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

  ChartSymbol getSymbol(Context context, PointData data, int index, PointGroup group, Set<ViewState> status) {
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
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex = p1 + start;
    });
    return data.length;
  }

  @override
  SeriesType get seriesType => SeriesType.point;

  ExtremeHelper<PointData>? _extremeHelper;

  ExtremeHelper<PointData> getExtremeHelper() {
    if (_extremeHelper != null) {
      return _extremeHelper!;
    }
    Map<PointData, PointGroup> groupMap = {};
    each(data, (group, p0) {
      each(group.data, (child, p1) {
        if (groupMap.containsKey(child)) {
          throw ChartError("存在相同ID的数据");
        }
        groupMap[child] = group;
      });
    });

    ExtremeHelper<PointData> helper = ExtremeHelper(
      (p0) => ['x${groupMap[p0]!.xAxisIndex}', 'y${groupMap[p0]!.yAxisIndex}'],
      (p0, index) {
        if (index.startsWith('x')) {
          return p0.x;
        }
        return p0.y;
      },
      groupMap.keys,
    );
    _extremeHelper = helper;
    return helper;
  }

  void clearExtreme() {
    _extremeHelper = null;
  }

  @override
  void notifyUpdateData() {
    clearExtreme();
    super.notifyUpdateData();
  }

  @override
  void notifyConfigChange() {
    clearExtreme();
    super.notifyConfigChange();
  }

}
