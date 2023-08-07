import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class BarSeries extends StackSeries<StackItemData, BarGroupData> {
  Corner corner;

  /// Group组的间隔
  SNumber groupGap;

  ///Group组中柱状图之间的间隔
  SNumber columnGap;

  /// Column组里面的间隔
  num innerGap;
  Color groupHoverColor = const Color(0xFFE3F2FD);

  ChartAlign? labelAlign;
  Fun4<StackItemData, BarGroupData, Set<ViewState>, Corner>? cornerFun;

  /// 背景样式
  Fun4<StackItemData?, BarGroupData, Set<ViewState>, AreaStyle?>? groupStyleFun;

  /// 标签对齐
  Fun4<StackItemData, BarGroupData, Set<ViewState>, ChartAlign>? labelAlignFun;

  BarSeries(
    super.data, {
    this.corner = Corner.zero,
    this.columnGap = const SNumber.number(4),
    this.groupGap = const SNumber.number(4),
    this.innerGap = 0,
    this.labelAlignFun,
    this.groupStyleFun,
    super.areaStyleFun,
    super.lineStyleFun,
    super.labelFormatFun,
    super.labelStyleFun,
    super.markLine,
    super.markPoint,
    super.markPointFun,
    super.markLineFun,
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

  ChartAlign getLabelAlign(Context context, StackItemData data, BarGroupData group, [Set<ViewState>? status]) {
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
}
