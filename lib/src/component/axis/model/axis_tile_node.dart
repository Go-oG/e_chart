import 'package:e_chart/e_chart.dart';
import 'package:flutter/rendering.dart';


///标识坐标轴的Title
class AxisTitleNode {
  final AxisName? name;
  TextDrawConfig config = TextDrawConfig(Offset.zero, align: Alignment.center);

  AxisTitleNode(this.name);
}
