import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/heatmap/heat_map_view.dart';
import 'package:flutter/painting.dart';

///热力图
///可以在日历坐标系和笛卡尔坐标系中使用
class HeatMapSeries extends RectSeries {
  List<HeatMapData> data;
  LabelStyle? labelStyle;
  Fun2<HeatMapData, LabelStyle>? labelStyleFun;
  Alignment? labelAlign;
  Fun2<HeatMapData, Alignment>? labelAlignFun;
  Fun2<HeatMapData, DynamicText?>? labelFormatFun;
  Fun2<HeatMapData, AreaStyle?>? areaStyleFun;
  Fun2<HeatMapData, LineStyle?>? borderStyleFun;
  Fun2<HeatMapData, ChartSymbol>? symbolFun;

  HeatMapSeries(
    this.data, {
    this.labelStyle,
    this.labelStyleFun,
    this.labelAlign,
    this.labelAlignFun,
    this.areaStyleFun,
    this.borderStyleFun,
    this.symbolFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.coordType = CoordType.calendar,
    super.gridIndex,
    super.calendarIndex = 0,
    super.tooltip,
    super.backgroundColor,
    super.id,
    super.clip,
  }) : super(polarIndex: -1, parallelIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return HeatMapView(this);
  }

  AreaStyle? getAreaStyle(Context context, HeatMapData data) {
    if (areaStyleFun != null) {
      return areaStyleFun!.call(data);
    }
    var theme = context.option.theme;
    return AreaStyle(color: theme.colors[data.dataIndex % theme.colors.length]).convert(data.status);
  }

  LineStyle? getBorderStyle(Context context, HeatMapData data) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data);
    }
    var theme = context.option.theme.funnelTheme;
    return theme.getBorderStyle();
  }

  ChartSymbol? getSymbol(Context context, HeatMapData data) {
    var fun = symbolFun;
    if (fun != null) {
      return fun.call(data);
    }
    return null;
  }

  LabelStyle? getLabelStyle(Context context, HeatMapData data) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data);
    }
    if (labelStyle != null) {
      return labelStyle;
    }
    var theme = context.option.theme;
    return theme.getLabelStyle()?.convert(data.status);
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

  DynamicText? formatData(Context context, HeatMapData data) {
    if (labelFormatFun != null) {
      return labelFormatFun?.call(data);
    }
    return formatNumber(data.value).toText();
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
  SeriesType get seriesType => SeriesType.heatmap;
}
