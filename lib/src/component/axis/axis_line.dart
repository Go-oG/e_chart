import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

//坐标轴样式相关的配置
class AxisStyle {
  bool show;
  AxisLabel? label;
  AxisSymbol symbol; //控制是否显示箭头
  Size symbolSize;
  Offset symbolOffset;

  LineStyle? lineStyle;
  LineStyle? splitLineStyle;
  AreaStyle? areaStyle;
  AreaStyle? splitAreaStyle;

  MainTick? tick;

  Fun3<int, int, LineStyle?>? styleFun;
  Fun3<int, int, MainTick?>? tickFun;
  Fun3<int, int, AreaStyle>? splitAreaFun;
  Fun3<int, int, LineStyle>? splitLineFun;

  AxisStyle(
      {this.show = true,
      this.label,
      this.symbol = AxisSymbol.none,
      this.symbolSize = const Size(10, 15),
      this.symbolOffset = Offset.zero,
      this.splitLineStyle,
      MainTick? tick,
      this.lineStyle,
      this.areaStyle,
      this.splitAreaStyle,
      this.styleFun,
      this.tickFun,
      this.splitAreaFun}) {
    if (tick != null) {
      this.tick = tick;
    }
  }

  LineStyle? getAxisLineStyle(int index, int maxIndex, AxisTheme theme) {
    LineStyle? style;
    if (styleFun != null) {
      style = styleFun?.call(index, maxIndex);
    } else {
      if (lineStyle != null) {
        style = lineStyle;
      } else {
        style = theme.getAxisLineStyle(index);
      }
    }
    return style;
  }

  LineStyle? getSplitLineStyle(int index, int maxIndex, AxisTheme theme) {
    LineStyle? style;
    if (splitLineFun != null) {
      style = splitLineFun?.call(index, maxIndex);
    } else {
      if (splitLineStyle != null) {
        style = splitLineStyle;
      } else {
        style = theme.getSplitLineStyle(index);
      }
    }
    return style;
  }

  AreaStyle? getSplitAreaStyle(int index, int maxIndex, AxisTheme theme){
    AreaStyle? style;
    if (splitAreaFun != null) {
      style = splitAreaFun?.call(index, maxIndex);
    } else {
      if (splitAreaStyle != null) {
        style = splitAreaStyle;
      } else {
        style = theme.getSplitAreaStyle(index);
      }
    }
    return style;
  }

  MainTick? getMainTick(int index, int maxIndex, AxisTheme theme) {
    MainTick? tick;
    if (tickFun != null) {
      tick = tickFun?.call(index, maxIndex);
    } else {
      if (this.tick != null) {
        tick = this.tick;
      } else {
        tick = theme.getMainTick();
      }
    }
    return tick;
  }

  MinorTick? getMinorTick(int index, int maxIndex, AxisTheme theme) {
    return getMainTick(index, maxIndex, theme)?.minorTick;
  }










}

enum AxisSymbol { none, single, double }
