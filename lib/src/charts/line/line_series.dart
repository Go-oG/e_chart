import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class LineSeries extends BaseGridSeries<LineItemData, LineGroupData> {
  bool connectNulls; // 是否连接空数据

  LabelStyle? labelStyle;

  Fun3<LineGroupData, int, LineStyle?>? lineStyleFun;
  Fun3<LineGroupData, int, AreaStyle?>? areaStyleFun;

  /// 符号样式
  Fun3<LineItemData, LineGroupData, ChartSymbol?>? symbolFun;

  ///返回非空值表示是阶梯折线图
  Fun2<LineGroupData, StepType?>? stepLineFun;

  /// 标签转换
  Fun3<LineItemData, LineGroupData, DynamicText?>? labelFormatFun;

  /// 标签样式
  Fun3<LineItemData, LineGroupData, LabelStyle>? labelStyleFun;

  /// 标记点、线相关的
  Fun2<LineGroupData, List<MarkPoint>>? markPointFun;
  Fun2<LineGroupData, List<MarkLine>>? markLineFun;

  LineSeries(
    super.data, {
    this.labelStyle,
    this.connectNulls = false,
    this.lineStyleFun,
    this.areaStyleFun,
    this.stepLineFun,
    this.symbolFun,
    this.labelFormatFun,
    this.labelStyleFun,
    this.markPointFun,
    this.markLineFun,
    super.direction,
    super.realtimeSort,
    super.legendHoverLink,
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

  LabelStyle? getLabelStyle(Context context, LineItemData data, LineGroupData group) {
    if (labelStyleFun != null) {
      return labelStyleFun?.call(data, group);
    }
    if (labelStyle != null) {
      return labelStyle;
    }
    var theme = context.option.theme;
    return LabelStyle(textStyle: TextStyle(color: theme.labelTextColor, fontSize: theme.labelTextSize));
  }

  DynamicText? formatData(Context context, LineItemData data, LineGroupData group) {
    if (labelFormatFun != null) {
      return labelFormatFun?.call(data, group);
    }
    return formatNumber(data.stackUp).toText();
  }

  AreaStyle? getAreaStyle(Context context, LineGroupData group, int groupIndex, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(group, groupIndex);
    }
    var chartTheme = context.option.theme;
    var theme = chartTheme.lineTheme;
    if (theme.fill) {
      Color fillColor = chartTheme.getColor(groupIndex).withOpacity(theme.opacity);
      return AreaStyle(color: fillColor).convert(status);
    }
    return null;
  }

  LineStyle? getBorderStyle(Context context, LineItemData data, LineGroupData group, int groupIndex, [Set<ViewState>? status]) {
    if (lineStyleFun != null) {
      return lineStyleFun?.call(group, groupIndex);
    }
    var chartTheme = context.option.theme;
    var theme = chartTheme.lineTheme;
    return theme.getLineStyle(chartTheme, groupIndex).convert(status);
  }
}
