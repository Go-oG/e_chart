import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/tooltip/tool_tip.dart';
import '../../style/area_style.dart';
import '../rect_coord.dart';
import 'axis_x.dart';
import 'axis_y.dart';

class GridConfig extends RectCoordConfig {
  ///grid区域是否包含坐标轴的刻度标签
  bool containLabel;
  AreaStyle? style;
  ToolTip? toolTip;
  List<XAxis> xAxisList = [XAxis()];
  List<YAxis> yAxisList = [YAxis()];

  GridConfig({
    List<XAxis>? xAxisList,
    List<YAxis>? yAxisList,
    this.containLabel = false,
    this.style,
    this.toolTip,
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
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
