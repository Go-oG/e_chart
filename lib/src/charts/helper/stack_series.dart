import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class StackSeries<T extends StackItemData, P extends StackGroupData<T>> extends ChartSeries {
  static const defaultAnimatorAttrs = AnimatorAttrs(
    curve: Curves.linear,
    updateDuration: Duration(milliseconds: 600),
    duration: Duration(milliseconds: 1200),
  );
  List<P> data;

  ///指示图形排列方式
  ///当为vertical时是竖直排列
  Direction direction;
  SelectedMode selectedMode;

  ///该动画样式只在柱状图中使用
  GridAnimatorStyle animatorStyle;

  // 是否启用图例hover的联动高亮
  bool legendHoverLink;

  // 是否启用实时排序
  bool realtimeSort;
  LabelStyle? labelStyle;

  ///在折线图中 area对应分割区域，柱状图中为Bar的区域
  Fun4<T?, P, Set<ViewState>, AreaStyle?>? areaStyleFun;

  ///在折线图中，Line对应线条 柱状图中为border
  Fun4<T?, P, Set<ViewState>, LineStyle?>? lineStyleFun;

  /// 标签转换
  Fun4<T, P, Set<ViewState>, DynamicText?>? labelFormatFun;

  /// 标签样式
  Fun4<T, P, Set<ViewState>, LabelStyle>? labelStyleFun;

  /// 标记点、线相关的
  /// 标记点、线相关的
  MarkLine? markLine;
  MarkPoint? markPoint;

  Fun2<P, List<MarkPoint>>? markPointFun;
  Fun2<P, List<MarkLine>>? markLineFun;

  StackSeries(
    this.data, {
    this.direction = Direction.vertical,
    this.selectedMode = SelectedMode.group,
    this.animatorStyle = GridAnimatorStyle.expand,
    this.legendHoverLink = true,
    this.realtimeSort = false,
    this.labelStyle,
    this.lineStyleFun,
    this.areaStyleFun,
    this.labelFormatFun,
    this.labelStyleFun,
    this.markLine,
    this.markPoint,
    this.markPointFun,
    this.markLineFun,
    super.animation = defaultAnimatorAttrs,
    super.backgroundColor,
    super.clip,
    super.coordSystem = CoordSystem.grid,
    super.gridIndex,
    super.polarIndex,
    super.id,
    super.tooltip,
    super.z,
  }) : super(radarIndex: -1, parallelIndex: -1, calendarIndex: -1);

  DataHelper<T, P, StackSeries>? _helper;

  DataHelper<T, P, StackSeries> get helper {
    _helper ??= DataHelper(this, data, direction);
    return _helper!;
  }

  @override
  void notifySeriesConfigChange() {
    _helper = null;
    super.notifySeriesConfigChange();
  }

  @override
  void notifyUpdateData() {
    _helper = null;
    super.notifyUpdateData();
  }

  List<MarkPoint> getMarkPoint(P group) {
    if (markPointFun != null) {
      return markPointFun!.call(group);
    }
    if (markPoint != null) {
      return [markPoint!];
    }
    return [];
  }

  List<MarkLine> getMarkLine(P group) {
    if (markLineFun != null) {
      return markLineFun!.call(group);
    }
    if (markLine != null) {
      return [markLine!];
    }
    return [];
  }

  LabelStyle? getLabelStyle(Context context, T data, P group, [Set<ViewState>? status]) {
    if (labelStyleFun != null) {
      return labelStyleFun?.call(data, group, status ?? {});
    }
    if (labelStyle != null) {
      return labelStyle;
    }
    var theme = context.option.theme;
    return LabelStyle(textStyle: TextStyle(color: theme.labelTextColor, fontSize: theme.labelTextSize));
  }

  DynamicText? formatData(Context context, T data, P group, [Set<ViewState>? status]) {
    if (labelFormatFun != null) {
      return labelFormatFun?.call(data, group, status ?? {});
    }
    return formatNumber(data.stackUp).toText();
  }

  AreaStyle? getAreaStyle(Context context, T? data, P group, int groupIndex, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group, status ?? {});
    }
    var chartTheme = context.option.theme;
    if (this is LineSeries) {
      var theme = chartTheme.lineTheme;
      if (theme.fill) {
        Color fillColor = chartTheme.getColor(groupIndex).withOpacity(theme.opacity);
        return AreaStyle(color: fillColor).convert(status);
      }
    } else {
      Color fillColor = chartTheme.getColor(groupIndex);
      return AreaStyle(color: fillColor).convert(status);
    }
    return null;
  }

  LineStyle? getLineStyle(Context context, T? data, P group, int groupIndex, [Set<ViewState>? status]) {
    if (lineStyleFun != null) {
      return lineStyleFun?.call(data, group, status ?? {});
    }
    var chartTheme = context.option.theme;
    if (this is LineSeries) {
      var theme = chartTheme.lineTheme;
      return theme.getLineStyle(chartTheme, groupIndex).convert(status);
    } else {
      var barTheme = context.option.theme.barTheme;
      return barTheme.getBorderStyle();
    }
  }
}

///动画样式
enum GridAnimatorStyle { expand, originExpand }
