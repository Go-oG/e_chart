import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/heatmap/heat_map_view.dart';
import 'package:flutter/painting.dart';

///热力图
///可以在日历坐标系和笛卡尔坐标系中使用
class HeatMapSeries extends RectSeries {
  List<HeatMapData> data;
  LabelStyle? labelStyle;
  Fun3<HeatMapData, Set<ViewState>, LabelStyle>? labelStyleFun;
  Alignment? labelAlign;
  Fun2<HeatMapData, Alignment>? labelAlignFun;
  Fun2<HeatMapData, DynamicText?>? labelFormatFun;
  Fun4<HeatMapData, int, Set<ViewState>, AreaStyle?>? areaStyleFun;
  Fun4<HeatMapData, int, Set<ViewState>, LineStyle?>? borderStyleFun;

  HeatMapSeries(
    this.data, {
    this.labelStyle,
    this.labelStyleFun,
    this.labelAlign,
    this.labelAlignFun,
    this.areaStyleFun,
    this.borderStyleFun,
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
    super.z,
  }) : super(polarIndex: -1, parallelIndex: -1, radarIndex: -1);

  @override
  ChartView? toView() {
    return HeatMapView(this);
  }

  AreaStyle? getAreaStyle(Context context, HeatMapData data, int index, Set<ViewState> status) {
    if (areaStyleFun != null) {
      return areaStyleFun!.call(data, index, status);
    }
    var theme = context.option.theme;
    return AreaStyle(color: theme.colors[index % theme.colors.length]).convert(status);
  }

  LineStyle? getBorderStyle(Context context, HeatMapData data, int index, Set<ViewState> status) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data, index, status);
    }
    var theme = context.option.theme.funnelTheme;
    return theme.getBorderStyle();
  }

  LabelStyle? getLabelStyle(Context context, HeatMapData data, Set<ViewState> status) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data, status);
    }
    if (labelStyle != null) {
      return labelStyle;
    }
    var theme = context.option.theme;
    return theme.getLabelStyle()?.convert(status);
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
}

class HeatMapData extends BaseItemData {
  dynamic x;
  dynamic y;
  num value;

  HeatMapData(this.x, this.y, this.value, {super.id, super.label}) {
    checkDataType(x);
    checkDataType(y);
  }

  @override
  String toString() {
    return "$runtimeType x:$x y:$y value:${value.toStringAsFixed(2)}";
  }
}
