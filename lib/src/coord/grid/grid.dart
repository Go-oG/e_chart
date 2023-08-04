import 'package:e_chart/e_chart.dart';
import 'package:flutter/painting.dart';

class Grid extends Coord {
  ///grid区域是否包含坐标轴的刻度标签
  bool containLabel;
  ToolTip? toolTip;
  List<XAxis> xAxisList = [XAxis()];
  List<YAxis> yAxisList = [YAxis()];

  Grid({
    List<XAxis>? xAxisList,
    List<YAxis>? yAxisList,
    this.containLabel = false,
    this.toolTip,
    super.brush,
    super.layoutParams = const LayoutParams.matchAll(padding: EdgeInsets.all(48)),
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.backgroundColor,
    super.id,
    super.show,
  }) {
    if (xAxisList != null) {
      this.xAxisList = xAxisList;
    }
    if (yAxisList != null) {
      this.yAxisList = yAxisList;
    }
  }

  @override
  CoordSystem get coordSystem => CoordSystem.grid;
}
