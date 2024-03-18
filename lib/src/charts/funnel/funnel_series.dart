import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/funnel/funnel_view.dart';
import 'package:flutter/material.dart';

class FunnelSeries extends RectSeries2<FunnelData> {
  double? maxValue;
  SNumber? itemHeight;
  Direction direction;
  Sort sort;
  double gap;
  Align2 align;

  ChartAlign? labelAlign;
  Fun2<FunnelData, ChartAlign>? labelAlignFun;

  FunnelSeries(
    super.data, {
    this.labelAlign = const ChartAlign(),
    this.maxValue,
    this.direction = Direction.vertical,
    this.sort = Sort.none,
    this.gap = 2,
    this.align = Align2.center,
    super.labelStyleFun,
    super.labelLineStyleFun,
    super.itemStyleFun,
    super.borderStyleFun,
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
  ChartView? toView(Context context) {
    return FunnelView(context, this);
  }

  @override
  AreaStyle getItemStyle(Context context, FunnelData data) {
    if (itemStyleFun != null) {
      return super.getItemStyle(context, data);
    }
    var theme = context.option.theme.funnelTheme;
    if (theme.colors.isNotEmpty) {
      return AreaStyle(color: theme.colors[data.dataIndex % theme.colors.length]);
    }
    var ctheme = context.option.theme;
    return AreaStyle(color: ctheme.colors[data.dataIndex % ctheme.colors.length]).convert(data.status);
  }

  @override
  LabelStyle getLabelStyle(Context context, FunnelData data) {
    if (labelStyleFun != null || labelStyle != null) {
      return super.getLabelStyle(context, data);
    }
    var theme = context.option.theme;
    return theme.getLabelStyle() ?? LabelStyle.empty;
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

  @override
  DynamicText formatData(Context context, FunnelData data) {
    if (labelFormatFun != null) {
      return super.formatData(context, data);
    }
    return formatNumber(data.value).toText();
  }

  @override
  SeriesType get seriesType => SeriesType.funnel;
}
