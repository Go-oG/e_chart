import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/funnel/funnel_view.dart';
import 'package:flutter/material.dart';

class FunnelSeries extends RectSeries {
  List<FunnelData> dataList;
  double? maxValue;
  SNumber? itemHeight;
  ChartAlign? labelAlign;
  Direction direction;
  Sort sort;
  double gap;
  Align2 align;
  LabelStyle? labelStyle;

  Fun2<FunnelData, AreaStyle>? areaStyleFun;
  Fun2<FunnelData, LineStyle?>? borderStyleFun;
  Fun2<FunnelData, LabelStyle>? labelStyleFun;
  Fun2<FunnelData, LineStyle>? labelLineStyleFun;
  Fun2<FunnelData, ChartAlign>? labelAlignFun;
  Fun2<FunnelData, DynamicText>? labelFormatFun;

  FunnelSeries(
    this.dataList, {
    this.labelAlign = const ChartAlign(),
    this.maxValue,
    this.direction = Direction.vertical,
    this.sort = Sort.none,
    this.gap = 2,
    this.align = Align2.center,
    this.labelStyleFun,
    this.labelLineStyleFun,
    this.areaStyleFun,
    this.borderStyleFun,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.tooltip,
  }) : super(
          coordType: null,
          calendarIndex: -1,
          parallelIndex: -1,
          polarIndex: -1,
          radarIndex: -1,
          gridIndex: -1,
        );

  @override
  ChartView? toView() {
    return FunnelView(this);
  }

  AreaStyle getAreaStyle(Context context, FunnelData data) {
    if (areaStyleFun != null) {
      return areaStyleFun!.call(data);
    }
    var theme = context.option.theme.funnelTheme;
    if (theme.colors.isNotEmpty) {
      return AreaStyle(color: theme.colors[data.dataIndex % theme.colors.length]);
    }
    var ctheme = context.option.theme;
    return AreaStyle(color: ctheme.colors[data.dataIndex % ctheme.colors.length]).convert(data.status);
  }

  LineStyle? getBorderStyle(Context context, FunnelData data) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data);
    }
    var theme = context.option.theme.funnelTheme;
    return theme.getBorderStyle();
  }

  LabelStyle? getLabelStyle(Context context, FunnelData data) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data);
    }
    if (labelStyle != null) {
      return labelStyle;
    }
    var theme = context.option.theme;
    return theme.getLabelStyle();
  }

  ChartAlign getLabelAlign(FunnelData data) {
    if (labelAlignFun != null) {
      return labelAlignFun!.call(data);
    }
    if (labelAlign != null) {
      return labelAlign!;
    }
    if (direction == Direction.vertical) {
      return const ChartAlign(align: Alignment.topCenter, inside: false);
    } else {
      return const ChartAlign(align: Alignment.centerRight, inside: false);
    }
  }

  DynamicText? formatData(Context context, FunnelData data) {
    if (labelFormatFun != null) {
      return labelFormatFun?.call(data);
    }
    return formatNumber(data.value).toText();
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(dataList, (item, i) {
      var name = item.label.text;
      if (name.isEmpty) {
        return;
      }
      list.add(LegendItem(name, RectSymbol()..itemStyle = getAreaStyle(context, item), seriesId: id));
    });
    return list;
  }

  @override
  int onAllocateStyleIndex(int start) {
    each(dataList, (p0, p1) {
      p0.styleIndex = p1 + start;
    });
    return dataList.length;
  }

  @override
  SeriesType get seriesType => SeriesType.funnel;
}
