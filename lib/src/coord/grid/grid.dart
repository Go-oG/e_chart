import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/coord/grid/grid_coord.dart';

class Grid extends Coord {
  ///grid区域是否包含坐标轴的刻度标签
  bool containLabel;
  List<XAxis> xAxisList = [XAxis()];
  List<YAxis> yAxisList = [YAxis()];

  double baseXScale;
  double baseYScale;

  Grid({
    List<XAxis>? xAxisList,
    List<YAxis>? yAxisList,
    this.containLabel = false,
    this.baseXScale = 1,
    this.baseYScale = 1,
    super.brush,
    super.layoutParams,
    super.toolTip,
    super.backgroundColor,
    super.id,
    super.show,
    super.freeDrag,
    super.freeLongPress,
  }) {
    if (xAxisList != null) {
      this.xAxisList = xAxisList;
    }
    if (yAxisList != null) {
      this.yAxisList = yAxisList;
    }
  }

  @override
  CoordType get coordSystem => CoordType.grid;

  @override
  CoordLayout<Coord>? toCoord(Context context) {
    return GridCoordImpl(context, this);
  }
}
