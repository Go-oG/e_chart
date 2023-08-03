import 'package:e_chart/e_chart.dart';
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

  Fun2<ItemData, AreaStyle>? areaStyleFun;
  Fun2<ItemData, LineStyle?>? borderStyleFun;
  Fun2<ItemData, LabelStyle>? labelStyleFun;
  Fun2<ItemData, LineStyle>? labelLineStyleFun;
  Fun2<ItemData, ChartAlign>? labelAlignFun;
  Fun2<ItemData, DynamicText>? labelFormatFun;

  FunnelSeries(
    this.dataList, {
    this.labelAlign = const ChartAlign(),
    this.maxValue,
    this.direction = Direction.vertical,
    this.sort = Sort.empty,
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
    super.enableClick,
    super.enableHover,
    super.enableDrag,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.clip,
    super.tooltip,
    super.z,
  }) : super(
          coordSystem: null,
          calendarIndex: -1,
          parallelIndex: -1,
          polarIndex: -1,
          radarIndex: -1,
          gridIndex: -1,
        );

  AreaStyle getAreaStyle(Context context, ItemData data, int index, [Set<ViewState>? status]) {
    if (areaStyleFun != null) {
      return areaStyleFun!.call(data);
    }
    var theme = context.option.theme.funnelTheme;
    if (theme.colors.isNotEmpty) {
      return AreaStyle(color: theme.colors[index % theme.colors.length]);
    }
    var ctheme = context.option.theme;
    return AreaStyle(color: ctheme.colors[index % ctheme.colors.length]).convert(status);
  }

  LineStyle? getBorderStyle(Context context, ItemData data, int index, [Set<ViewState>? status]) {
    if (borderStyleFun != null) {
      return borderStyleFun!.call(data);
    }
    var theme = context.option.theme.funnelTheme;
    return theme.getBorderStyle();
  }

  LabelStyle? getLabelStyle(Context context, ItemData data) {
    if (labelStyleFun != null) {
      return labelStyleFun!.call(data);
    }
    if (labelStyle != null) {
      return labelStyle;
    }
    var theme = context.option.theme;
    TextStyle textStyle = TextStyle(color: theme.labelTextColor, fontSize: theme.labelTextSize);
    return LabelStyle(textStyle: textStyle);
  }

  ChartAlign getLabelAlign(ItemData data) {
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

  DynamicText? formatData(Context context, ItemData data) {
    if (labelFormatFun != null) {
      return labelFormatFun?.call(data);
    }
    return formatNumber(data.value).toText();
  }
}
