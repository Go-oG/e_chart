import 'dart:ui';

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

  LinkageStyle linkageStyle;

  Fun3<BarItemData, BarGroupData, AreaStyle?>? areaStyleFun;
  Fun3<BarItemData, BarGroupData, LineStyle?>? borderStyleFun;
  Fun3<BarItemData, BarGroupData, Corner>? cornerFun;

  ///绘制对齐
  Fun3<BarItemData, BarGroupData, Align2>? alignFun;

  /// 背景样式
  Fun3<BarItemData, BarGroupData, AreaStyle?>? groupStyleFun;

  /// 标签转换
  Fun3<BarItemData, BarGroupData, String>? labelFun;

  /// 标签样式
  Fun3<BarItemData, BarGroupData, LabelStyle>? labelStyleFun;

  /// 标签对齐
  Fun3<BarItemData, BarGroupData, Position2>? labelAlignFun;

  /// 标记点、线相关的
  Fun2<BarGroupData, MarkPoint>? markPointFun;

  Fun2<BarGroupData, MarkLine>? markLineFun;

  BarSeries(
    super.data, {
    this.corner = Corner.zero,
    this.columnGap = const SNumber.number(4),
    this.groupGap = const SNumber.number(4),
    this.innerGap = 0,
    this.linkageStyle = LinkageStyle.group,
    this.areaStyleFun,
    this.borderStyleFun,
    this.alignFun,
    this.labelFun,
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
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.clip,
    super.z,
    super.tooltip,
  });
}

/// 标识一个Group的手势联动策略
enum LinkageStyle {
  none,
  single, // 只有自身变化
  group, // 联动Group
}
