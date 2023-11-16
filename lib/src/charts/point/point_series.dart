import 'package:e_chart/e_chart.dart';

import 'point_view.dart';

class PointSeries extends ChartListSeries<PointData> {
  Fun2<PointData, ChartSymbol>? symbolFun;

  PointSeries(
    super.data, {
    this.symbolFun,
    super.gridIndex,
    super.polarIndex = 0,
    super.calendarIndex = 0,
    super.coordType = CoordType.grid,
    super.tooltip,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.borderStyleFun,
    super.itemStyleFun,
    super.labelFormatFun,
    super.labelLineStyleFun,
    super.labelStyle,
    super.labelStyleFun,
    super.name,
    super.useSingleLayer,
  }) : super(radarIndex: -1, parallelIndex: -1);

  @override
  ChartView? toView() {
    return PointView(this);
  }

  ChartSymbol getSymbol(Context context, PointData data) {
    var fun = symbolFun;
    if (fun != null) {
      return fun.call(data);
    }

    return CircleSymbol(
      radius: 10,
      itemStyle: AreaStyle(color: context.option.theme.getColor(data.dataIndex)).convert(data.status),
    );
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];


  @override
  SeriesType get seriesType => SeriesType.point;

  ExtremeHelper<PointData>? _extremeHelper;

  ExtremeHelper<PointData> getExtremeHelper() {
    if (_extremeHelper != null) {
      return _extremeHelper!;
    }

    ExtremeHelper<PointData> helper = ExtremeHelper(
      (p0) => ['x${p0.domainAxis}', 'y${p0.valueAxis}'],
      (p0, index) {
        if (index.startsWith('x')) {
          return p0.domain;
        }
        return p0.value;
      },
      data,
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
