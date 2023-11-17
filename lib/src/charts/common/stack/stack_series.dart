import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

abstract class StackSeries<T extends StackItemData, G extends StackGroupData<T, G>> extends ChartSeries {
  static const defaultAnimatorAttrs = AnimatorOption(
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
  Fun2<StackData<T, G>, Corner>? cornerFun;

  /// Group组的间隔
  SNumber groupGap;

  ///Group组中柱状图之间的间隔
  SNumber columnGap;

  /// Column组里面的间隔
  num innerGap;
  Color groupHoverColor = const Color(0xFFE3F2FD);
  ChartAlign? labelAlign;

  // 是否启用图例hover的联动高亮
  bool legendHoverLink;

  ///是否启用实时排序(只在柱状图中生效)
  bool realtimeSort;
  bool dynamicLabel;
  Sort sort;
  int? sortCount;

  ///当图表有层叠布局时是否表示为百分比
  bool stackIsPercent;

  ///是否启用坐标轴数据动态范围(如果启用了，那么坐标轴将实时变化)
  ///需要搭配 坐标轴start0 使用
  bool dynamicRange;

  ///该动画样式只在柱状图中使用
  GridAnimatorStyle animatorStyle;

  ///在折线图中 area对应分割区域，柱状图中为Bar的区域
  Fun3<StackData<T, G>, G, AreaStyle?>? areaStyleFun;

  ///在折线图中，Line对应线条 柱状图中为border
  Fun3<StackData<T, G>, G, LineStyle?>? lineStyleFun;

  /// 标签转换
  Fun3<dynamic, G, DynamicText?>? labelFormatFun;

  /// 标签对齐
  Fun2<StackData<T, G>, ChartAlign>? labelAlignFun;

  /// 标签样式
  LabelStyle? labelStyle;
  Fun2<StackData<T, G>, LabelStyle?>? labelStyleFun;

  /// 背景样式
  Fun2<G, AreaStyle?>? groupStyleFun;

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
    this.stackIsPercent = false,
    this.dynamicRange = false,
    this.legendHoverLink = true,
    this.realtimeSort = false,
    this.dynamicLabel = false,
    this.sort = Sort.asc,
    this.sortCount,
    this.corner = Corner.zero,
    this.cornerFun,
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
    super.coordType = CoordType.grid,
    super.gridIndex,
    super.polarIndex,
    super.id,
    super.tooltip,
  }) : super(radarIndex: -1, parallelIndex: -1, calendarIndex: -1);

  DataHelper<T, G>? _helper;

  DataHelper<T, G> getHelper(Context context) {
    _helper ??= buildHelper(context);
    return _helper!;
  }

  DataHelper<T, G> buildHelper(Context context) {
    return DataHelper<T, G>(
      coordType ?? CoordType.grid,
      polarIndex,
      data,
      direction,
      realtimeSort,
      sort,
      sortCount,
      stackIsPercent: stackIsPercent,
    );
  }

  @override
  void notifyConfigChange() {
    _helper = null;
    super.notifyConfigChange();
  }

  @override
  void notifyUpdateData() {
    _helper?.dispose();
    _helper = null;
    super.notifyUpdateData();
  }

  @override
  int onAllocateStyleIndex(int start) {
    each(data, (p0, p1) {
      p0.styleIndex = start + p1;
    });
    return data.length;
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

  DynamicText? formatData(Context context, dynamic data, G group) {
    if (labelFormatFun != null) {
      return labelFormatFun?.call(data, group);
    }
    return formatNumber(data.stackUp).toText();
  }

  AreaStyle getAreaStyle(Context context, StackData<T, G> data, G group) {
    var fun = areaStyleFun;
    if (fun != null) {
      return fun.call(data, group) ?? AreaStyle.empty;
    }
    var chartTheme = context.option.theme;
    if (this is LineSeries) {
      var theme = chartTheme.lineTheme;
      if (theme.fill) {
        var fillColor = chartTheme.getColor(group.styleIndex).withOpacity(theme.opacity);
        return AreaStyle(color: fillColor).convert(data.status);
      }
    } else {
      return chartTheme.getAreaStyle(group.styleIndex).convert(data.status);
    }
    return AreaStyle.empty;
  }

  LineStyle getLineStyle(Context context, StackData<T, G> data, G group) {
    var fun = lineStyleFun;
    if (fun != null) {
      return fun.call(data, group) ?? LineStyle.empty;
    }
    var chartTheme = context.option.theme;
    if (this is LineSeries) {
      var theme = chartTheme.lineTheme;
      return theme.getLineStyle(chartTheme, group.styleIndex).convert(data.status);
    } else {
      return context.option.theme.barTheme.getBorderStyle() ?? LineStyle.empty;
    }
  }

  LabelStyle getLabelStyle(Context context, StackData<T, G> data) {
    var fun = labelStyleFun;
    if (fun != null) {
      return fun.call(data) ?? LabelStyle.empty;
    }
    if (labelStyle != null) {
      return labelStyle!;
    }
    var theme = context.option.theme;
    return (theme.getLabelStyle()?.convert(data.status)) ?? LabelStyle.empty;
  }

  ChartAlign getLabelAlign(Context context, StackData<T, G> data) {
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

  Corner? getCorner(StackData<T, G> data) {
    if (data.dataIsNull) {
      return null;
    }
    var fun = cornerFun;
    if (fun != null) {
      return fun.call(data);
    }
    return corner;
  }

  bool get isVertical => direction == Direction.vertical;

  bool get isHorizontal => direction == Direction.horizontal;

  @override
  List<LegendItem> getLegendItem(Context context) {
    List<LegendItem> list = [];
    each(data, (group, i) {
      var name = group.name;
      if (name.isEmpty) {
        return;
      }
      //  var fillColor = context.option.theme.getColor(group.styleIndex);
      var fillColor = context.option.theme.getColor(i);
      list.add(LegendItem(
        name.toText(),
        RectSymbol()..itemStyle = AreaStyle(color: fillColor),
        seriesId: id,
      ));
    });
    return list;
  }
}

///动画样式
enum GridAnimatorStyle { expand, originExpand }
