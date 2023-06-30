import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/tooltip/tool_tip.dart';
import '../rect_coord.dart';
import 'axis/axis_x.dart';
import 'axis/axis_y.dart';

class GridConfig extends RectCoordConfig {
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
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
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
