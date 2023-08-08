import 'package:e_chart/e_chart.dart';
import 'package:flutter/material.dart';

///坐标轴主题
class AxisTheme {
  bool showAxisLine = true;
  Color axisLineColor = const Color(0xFF6E7079);
  num axisLineWidth = 1;

  MainTick? tick = MainTick();
  MinorTick? minorTick;

  bool showLabel = true;
  Color labelColor = const Color(0xFF6E7079);
  num labelSize = 13;

  bool showMinorLabel = false;
  Color minorLabelColor = const Color(0xFF6E7079);
  num minorLabelSize = 13;

  bool showSplitLine = false;
  num splitLineWidth = 1;
  List<Color> splitLineColors = [
    const Color(0xFFE0E6F1),
  ];

  bool showSplitArea = false;
  List<Color> splitAreaColors = [
    const Color.fromRGBO(250, 250, 250, 0.2),
    const Color.fromRGBO(210, 219, 238, 0.2),
  ];

  MainTick? getMainTick() {
    if (tick == null || !tick!.show) {
      return null;
    }
    return tick;
  }

  MinorTick? getMinorTick() {
    if (minorTick == null || !minorTick!.show) {
      return null;
    }
    return minorTick;
  }

  Color? getSplitLineColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (!showSplitLine) {
      return null;
    }
    if (splitLineColors.isNotEmpty) {
      return splitLineColors[index % splitLineColors.length];
    }
    return axisLineColor;
  }

  LineStyle? getSplitLineStyle(int index) {
    Color? color = getSplitLineColor(index);
    if (color != null) {
      return LineStyle(color: color, width: splitLineWidth);
    }
    return null;
  }

  Color? getSplitAreaColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (!showSplitArea) {
      return null;
    }
    if (splitAreaColors.isNotEmpty) {
      return splitAreaColors[index % splitAreaColors.length];
    }
    return Colors.white;
  }

  AreaStyle? getSplitAreaStyle(int index) {
    Color? color = getSplitAreaColor(index);
    if (color != null) {
      return AreaStyle(color: color);
    }
    return null;
  }

  Color? getAxisLineColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (!showAxisLine) {
      Logger.i("不显示该轴");
      return null;
    }
    return axisLineColor;
  }

  LineStyle? getAxisLineStyle(int index) {
    Color? color = getAxisLineColor(index);
    if (color != null) {
      return LineStyle(color: color, width: axisLineWidth);
    }
    return null;
  }
}
