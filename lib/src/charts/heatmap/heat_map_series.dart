import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/heatmap/heat_map_view.dart';
import 'package:flutter/painting.dart';

///热力图
///可以在日历坐标系和笛卡尔坐标系中使用
class HeatMapSeries extends ChartListSeries<HeatMapData> {
  Alignment? labelAlign;
  Fun2<HeatMapData, Alignment>? labelAlignFun;
  Fun2<HeatMapData, AreaStyle?>? areaStyleFun;
  Fun2<HeatMapData, ChartSymbol>? symbolFun;

  HeatMapSeries(
    super.data, {
    super.labelStyle,
    super.labelStyleFun,
    this.labelAlign,
    this.labelAlignFun,
    this.areaStyleFun,
    super.borderStyleFun,
    this.symbolFun,
    super.layoutParams,
    super.animation,
    super.coordType = CoordType.calendar,
    super.gridIndex,
    super.calendarIndex = 0,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.clip,
    super.itemStyleFun,
    super.labelFormatFun,
    super.labelLineStyleFun,
    super.name,
    super.useSingleLayer,
  }) : super(polarIndex: -1, parallelIndex: -1, radarIndex: -1);

  @override
  ChartView? toView(Context context) {
    return HeatMapView(context, this);
  }

  ChartSymbol? getSymbol(Context context, HeatMapData data) {
    var fun = symbolFun;
    if (fun != null) {
      return fun.call(data);
    }
    return null;
  }

  Alignment getLabelAlign(HeatMapData data) {
    if (labelAlignFun != null) {
      return labelAlignFun!.call(data);
    }
    if (labelAlign != null) {
      return labelAlign!;
    }
    return Alignment.topCenter;
  }

  @override
  DynamicText formatData(Context context, HeatMapData data) {
    if (labelFormatFun != null) {
      return super.formatData(context, data);
    }
    return formatNumber(data.value).toText();
  }

  @override
  List<LegendItem> getLegendItem(Context context) => [];

  @override
  SeriesType get seriesType => SeriesType.heatmap;
}
