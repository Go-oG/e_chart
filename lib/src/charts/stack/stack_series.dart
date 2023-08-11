import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

class StackSeries<T extends StackItemData, G extends StackGroupData<T>> extends ChartSeries {
  static const defaultAnimatorAttrs = AnimatorAttrs(
    curve: Curves.linear,
    updateDuration: Duration(milliseconds: 600),
    duration: Duration(milliseconds: 1200),
  );
  List<G> data;

  ///指示图形排列方式
  ///当为vertical时是竖直排列
  Direction direction;
  SelectedMode selectedMode;

  Corner corner;

  /// Group组的间隔
  SNumber groupGap;

  ///Group组中柱状图之间的间隔
  SNumber columnGap;

  /// Column组里面的间隔
  num innerGap;
  Color groupHoverColor = const Color(0xFFE3F2FD);
  ChartAlign? labelAlign;

  ///该动画样式只在柱状图中使用
  GridAnimatorStyle animatorStyle;

  // 是否启用图例hover的联动高亮
  bool legendHoverLink;

  ///是否启用实时排序(只在柱状图中生效)
  ///当启用了实时排序则只能但一个堆叠组
  bool realtimeSort;
  Sort sort;
  int? sortCount;

  LabelStyle? labelStyle;

  ///在折线图中 area对应分割区域，柱状图中为Bar的区域
  Fun4<T?, G, Set<ViewState>, AreaStyle?>? areaStyleFun;

  ///在折线图中，Line对应线条 柱状图中为border
  Fun4<T?, G, Set<ViewState>, LineStyle?>? lineStyleFun;

  /// 标签转换
  Fun4<T, G, Set<ViewState>, DynamicText?>? labelFormatFun;

  /// 标签对齐
  Fun4<T, G, Set<ViewState>, ChartAlign>? labelAlignFun;

  /// 标签样式
  Fun4<T, G, Set<ViewState>, LabelStyle?>? labelStyleFun;

  Fun4<T, G, Set<ViewState>, Corner>? cornerFun;

  /// 背景样式
  Fun4<T?, G, Set<ViewState>, AreaStyle?>? groupStyleFun;

  /// 标记点、线相关的
  /// 标记点、线相关的
  MarkLine? markLine;
  MarkPoint? markPoint;

  Fun2<G, List<MarkPoint>>? markPointFun;
  Fun2<G, List<MarkLine>>? markLineFun;

  StackSeries(
    this.data, {
    this.direction = Direction.vertical,
    this.selectedMode = SelectedMode.group,
    this.animatorStyle = GridAnimatorStyle.expand,
    this.legendHoverLink = true,
    this.realtimeSort = false,
    this.sort = Sort.asc,
    this.sortCount,
    this.corner = Corner.zero,
    this.columnGap = const SNumber.number(4),
    this.groupGap = const SNumber.number(4),
    this.innerGap = 0,
    this.labelAlignFun,
    this.groupStyleFun,
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

  DataHelper<T, G, StackSeries>? _helper;

  DataHelper<T, G, StackSeries> get helper {
    _helper ??= buildHelper();
    return _helper!;
  }

  DataHelper<T, G, StackSeries> buildHelper() {
    return DataHelper(this, data, direction, realtimeSort, sort);
  }

  @override
  void notifySeriesConfigChange() {
    _helper = null;
    super.notifySeriesConfigChange();
  }

  @override
  void notifyUpdateData() {
    _helper = null;
    Future(() {
      helper.getCrossExtreme(CoordSystem.polar, -1);
    }).then((value) => super.notifyUpdateData());
  }

  List<MarkPoint> getMarkPoint(G group) {
    if (markPointFun != null) {
      return markPointFun!.call(group);
    }
    if (markPoint != null) {
      return [markPoint!];
    }
    return [];
  }

  List<MarkLine> getMarkLine(G group) {
    if (markLineFun != null) {
      return markLineFun!.call(group);
    }
    if (markLine != null) {
      return [markLine!];
    }
    return [];
  }

  LabelStyle? getLabelStyle(Context context, T data, G group, [Set<ViewState>? status]) {
    if (labelStyleFun != null) {
      return labelStyleFun?.call(data, group, status ?? {});
    }
    if (labelStyle != null) {
      return labelStyle;
    }
    var theme = context.option.theme;
    return LabelStyle(textStyle: TextStyle(color: theme.labelTextColor, fontSize: theme.labelTextSize));
  }

  DynamicText? formatData(Context context, T data, G group, [Set<ViewState>? status]) {
    if (labelFormatFun != null) {
      return labelFormatFun?.call(data, group, status ?? {});
    }
    return formatNumber(data.stackUp).toText();
  }

  AreaStyle? getAreaStyle(Context context, T? data, G group, int styleIndex, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun?.call(data, group, status ?? {});
    }
    var chartTheme = context.option.theme;
    if (this is LineSeries) {
      var theme = chartTheme.lineTheme;
      if (theme.fill) {
        Color fillColor = chartTheme.getColor(styleIndex).withOpacity(theme.opacity);
        return AreaStyle(color: fillColor).convert(status);
      }
    } else {
      Color fillColor = chartTheme.getColor(styleIndex);
      return AreaStyle(color: fillColor).convert(status);
    }
    return null;
  }

  LineStyle? getLineStyle(Context context, T? data, G group, int styleIndex, [Set<ViewState>? status]) {
    if (lineStyleFun != null) {
      return lineStyleFun?.call(data, group, status ?? {});
    }
    var chartTheme = context.option.theme;
    if (this is LineSeries) {
      var theme = chartTheme.lineTheme;
      return theme.getLineStyle(chartTheme, styleIndex).convert(status);
    } else {
      var barTheme = context.option.theme.barTheme;
      return barTheme.getBorderStyle();
    }
  }

  ChartAlign getLabelAlign(Context context, T data, G group, [Set<ViewState>? status]) {
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

  bool get isVertical => direction == Direction.vertical;
}

///动画样式
enum GridAnimatorStyle { expand, originExpand }
