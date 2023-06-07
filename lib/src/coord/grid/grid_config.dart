import 'package:e_chart/src/model/enums/coordinate.dart';

import '../../component/tooltip/tool_tip.dart';
import '../../style/area_style.dart';
import '../rect_coord.dart';
import 'axis_x.dart';
import 'axis_y.dart';

class GridConfig extends RectCoordConfig {
  ///grid区域是否包含坐标轴的刻度标签
  final bool containLabel;
  final AreaStyle? style;
  final ToolTip? toolTip;
  final List<XAxis> xAxisList;
  final List<YAxis> yAxisList;

  const GridConfig({
    this.xAxisList = const [XAxis()],
    this.yAxisList = const [YAxis()],
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
  });

  @override
  CoordSystem get coordSystem => CoordSystem.grid;
}
