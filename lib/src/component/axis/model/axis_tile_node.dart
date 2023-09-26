import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';

///标识坐标轴的Title
class AxisTitleNode {
  final AxisName? name;
  late TextDraw config;

  AxisTitleNode(this.name) {
    config = TextDraw(name?.name ?? DynamicText.empty, LabelStyle.empty, Offset.zero, align: Alignment.center);
  }
}
