import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/funnel/funnel_view.dart';
import 'package:flutter/material.dart';

class FunnelSeries extends RectSeries {
  List<ItemData> dataList;
  double? maxValue;
  SNumber? itemHeight;
  ChartAlign? labelAlign;
  Direction direction;
  Sort sort;
  double gap;

  Align2 align;

  LabelStyle? labelStyle;

  Fun3<ItemData, Set<ViewState>, AreaStyle>? areaStyleFun;
  Fun3<ItemData, Set<ViewState>, LineStyle?>? borderStyleFun;
  Fun3<ItemData, Set<ViewState>, LabelStyle>? labelStyleFun;
  Fun3<ItemData, Set<ViewState>, LineStyle>? labelLineStyleFun;
  Fun3<ItemData, Set<ViewState>, ChartAlign>? labelAlignFun;
  Fun3<ItemData, Set<ViewState>, DynamicText>? labelFormatFun;

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

  AreaStyle getAreaStyle(Context context, ItemData data, int index, Set<ViewState> status) {
    if (areaStyleFun != null) {
      return areaStyleFun!.call(data, status);
    }
    var theme = context.option.theme.funnelTheme;
    if (theme.colors.isNotEmpty) {
      return AreaStyle(color: theme.colors[index % theme.colors.length]);
    }
    var ctheme = context.option.theme;
    return AreaStyle(color: ctheme.colors[index % ctheme.colors.length]).convert(status);
  }

  LineStyle? getBorderStyle(Context context, ItemData data, int index, Set<ViewState> status) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data, status);
    }
    var theme = context.option.theme.funnelTheme;
    return theme.getBorderStyle();
  }

  LabelStyle? getLabelStyle(Context context, ItemData data, int index, Set<ViewState> status) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data, status);
    }
    if (labelStyle != null) {
      return labelStyle;
    }
    var theme = context.option.theme;
    return theme.getLabelStyle();
  }

  ChartAlign getLabelAlign(ItemData data, Set<ViewState> status) {
    if (labelAlignFun != null) {
      return labelAlignFun!.call(data, status);
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

  DynamicText? formatData(Context context, ItemData data, Set<ViewState> status) {
    if (labelFormatFun != null) {
      return labelFormatFun?.call(data, status);
    }
    return formatNumber(data.value).toText();
  }

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(dataList, (item, i) {
      var name = item.name;
      if (name == null || name.isEmpty) {
        return;
      }
      list.add(LegendItem(name, RectSymbol()..itemStyle = getAreaStyle(context, item, i, {}), seriesId: id));
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
