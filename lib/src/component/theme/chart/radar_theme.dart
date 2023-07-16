import 'package:flutter/material.dart';

import '../../../model/chart_error.dart';
import '../../../style/area_style.dart';
import '../../../style/line_style.dart';
import '../../../symbol/index.dart';
///Radar主题
class RadarTheme {
  num lineWidth = 2;
  List<num> dashList = [];
  bool showSymbol = true;
  ChartSymbol symbol = EmptySymbol();
  bool fill = false;

  ///用于坐标轴相关的
  List<Color> splitColors = [
    const Color(0xFFFFFFFF),
  ];
  List<Color> borderColors = [
    const Color(0xFFFFFFFF),
  ];
  num borderWidth = 1;

  Color getSplitLineColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (borderColors.isNotEmpty) {
      return borderColors[index % borderColors.length];
    }
    return Colors.black26;
  }

  LineStyle getSplitLineStyle(int index) {
    Color color = getSplitLineColor(index);
    return LineStyle(color: color, width: borderWidth);
  }

  Color getSplitAreaColor(int index) {
    if (index < 0) {
      throw ChartError('Index 必须大于0');
    }
    if (splitColors.isNotEmpty) {
      return splitColors[index % splitColors.length];
    }
    return Colors.white;
  }

  AreaStyle getSplitAreaStyle(int index) {
    Color color = getSplitAreaColor(index);
    return AreaStyle(color: color);
  }
}
