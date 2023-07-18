import 'package:e_chart/src/model/enums/coordinate.dart';
import 'package:flutter/painting.dart';

import '../../component/tooltip/tool_tip.dart';
import '../coord_config.dart';
import 'axis/axis_x.dart';
import 'axis/axis_y.dart';

class GridConfig extends CoordConfig {
  ///grid区域是否包含坐标轴的刻度标签
  bool containLabel;
  ToolTip? toolTip;
  List<XAxis> xAxisList = [XAxis()];
  List<YAxis> yAxisList = [YAxis()];

  GridConfig({
    List<XAxis>? xAxisList,
    List<YAxis>? yAxisList,
    this.containLabel = false,
    this.toolTip,
    super.padding=const EdgeInsets.only(left: 24,right: 24,bottom: 16,top: 16),
    super.margin,
    super.width,
    super.height,
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
