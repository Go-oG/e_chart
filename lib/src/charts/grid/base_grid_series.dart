import '../../core/index.dart';
import '../../model/index.dart';
import 'base_data.dart';

class BaseGridSeries<T extends BaseItemData, P extends BaseGroupData<T>> extends ChartSeries {
  List<P> data;
  Direction direction;

  BaseGridSeries(
    this.data, {
    this.direction = Direction.vertical,
    super.animation,
    super.backgroundColor,
    super.calendarIndex,
    super.clip,
    super.coordSystem,
    super.enableClick,
    super.enableDrag,
    super.enableHover,
    super.enableScale,
    super.id,
    super.parallelIndex,
    super.polarAxisIndex,
    super.radarIndex,
    super.tooltip,
    super.xAxisIndex,
    super.yAxisIndex,
    super.z,
  });
}
