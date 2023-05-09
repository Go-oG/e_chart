
import '../../model/enums/coordinate.dart';
import '../../model/multi_data.dart';
import '../series.dart';

class LineSeries extends RectSeries {
  final List<MultiData> data;

  LineSeries(this.data,{
    super.leftMargin,
    super.topMargin,
    super.rightMargin,
    super.bottomMargin,
    super.width,
    super.height,
    super.animation,
    super.coordSystem = CoordSystem.grid,
    super.xAxisIndex = 0,
    super.yAxisIndex = 0,
    super.calendarIndex = 0,
    super.parallelIndex,
    super.polarAxisIndex,
    super.radarIndex,
    super.clip,
    super.tooltip,
    super.touch,
    super.z,
  }) : super();
}
