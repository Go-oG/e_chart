import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class BarSeries extends BaseGridSeries<BarItemData, BarGroupData> {
  Corner corner;

  // Group组的间隔
  SNumber groupGap;

  //Group组中柱状图之间的间隔
  SNumber columnGap;

  // Column组里面的间隔
  num innerGap;
  Color groupHoverColor = const Color(0xFFE3F2FD);

  LabelStyle? labelStyle;

  ChartAlign? labelAlign;

  Fun4<BarItemData, BarGroupData, Set<ViewState>, AreaStyle?>? areaStyleFun;
  Fun4<BarItemData, BarGroupData, Set<ViewState>, LineStyle?>? borderStyleFun;
  Fun4<BarItemData, BarGroupData, Set<ViewState>, Corner>? cornerFun;

  /// 背景样式
  Fun4<BarItemData?, BarGroupData, Set<ViewState>, AreaStyle?>? groupStyleFun;

  /// 标签转换
  Fun4<BarItemData, BarGroupData, Set<ViewState>, DynamicText?>? labelFormat;

  /// 标签样式
  Fun4<BarItemData, BarGroupData, Set<ViewState>, LabelStyle?>? labelStyleFun;

  /// 标签对齐
  Fun4<BarItemData, BarGroupData, Set<ViewState>, ChartAlign>? labelAlignFun;

  /// 标记点、线相关的
  Fun2<BarGroupData, MarkPoint>? markPointFun;

  Fun2<BarGroupData, MarkLine>? markLineFun;

  BarSeries(
    super.data, {
    this.corner = Corner.zero,
    this.columnGap = const SNumber.number(4),
    this.groupGap = const SNumber.number(4),
    this.innerGap = 0,
    this.areaStyleFun,
    this.borderStyleFun,
    this.labelFormat,
    this.labelStyleFun,
    this.labelAlignFun,
    this.groupStyleFun,
    this.markPointFun,
    this.markLineFun,
    super.realtimeSort,
    super.legendHoverLink,
    super.direction,
    super.animatorStyle,
    super.selectedMode,
    super.gridIndex,
    super.polarIndex = -1,
    super.coordSystem = CoordSystem.grid,
    super.animation,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
    super.tooltip,
  });

  LabelStyle? getLabelStyle(Context context, BarItemData data, BarGroupData group, [Set<ViewState>? status]) {
    if (labelStyleFun != null) {
      return labelStyleFun?.call(data, group, status ?? {});
    }
    if (labelStyle != null) {
      return labelStyle;
    }
    var theme = context.option.theme;
    return LabelStyle(textStyle: TextStyle(color: theme.labelTextColor, fontSize: theme.labelTextSize));
  }

  ChartAlign getLabelAlign(Context context, BarItemData data, BarGroupData group, [Set<ViewState>? status]) {
    if (labelAlignFun != null) {
      return labelAlignFun!.call(data, group, status ?? {});
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

  DynamicText? formatData(Context context, BarItemData data, BarGroupData group, [Set<ViewState>? status]) {
    if (labelFormat != null) {
      return labelFormat?.call(data, group, status ?? {});
    }
    return formatNumber(data.stackUp).toText();
  }

  AreaStyle? getAreaStyle(Context context, BarItemData data, BarGroupData group, int groupIndex, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group, status ?? {});
    }
    var chartTheme = context.option.theme;
    return AreaStyle(color: chartTheme.getColor(groupIndex)).convert(status);
  }

  LineStyle? getBorderStyle(Context context, BarItemData data, BarGroupData group, int groupIndex, [Set<ViewState>? status]) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data, group, status ?? {});
    }
    var theme = context.option.theme.barTheme;
    return theme.getBorderStyle()?.convert(status);
  }
}
