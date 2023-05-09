
import '../../component/tooltip/tool_tip.dart';
import '../../style/area_style.dart';
import '../coord_layout.dart';
import '../rect_coord.dart';
import 'axis_x.dart';
import 'axis_y.dart';
import 'grid_layout.dart';

class GridInner extends RectCoordinate {
  ///grid区域是否包含坐标轴的刻度标签
  final bool containLabel;
  final AreaStyle style;
  final ToolTip? toolTip;
  final List<XAxis> xAxisList;
  final List<YAxis> yAxisList;

  const GridInner({
    required this.containLabel,
    required this.style,
    required this.toolTip,
    required this.xAxisList,
    required this.yAxisList,
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
  CoordinateLayout toLayout() {
    return GridLayout(this);
  }
}
