import '../../model/enums/coordinate.dart';
import '../../model/multi_data.dart';
import '../series.dart';

class PointSeries extends RectSeries {
  final List<PointData> data;

  PointSeries(
    this.data, {
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    super.polarAxisIndex = 0,
    super.calendarIndex = 0,
    super.coordSystem = CoordSystem.grid,
    super.tooltip,
    super.animation,
        super.enableClick,
        super.enableHover,
        super.enableDrag,
        super.enableScale,
    super.clip,
    super.z,
  }) : super(
          radarIndex: -1,
          parallelIndex: -1,
        );
}
