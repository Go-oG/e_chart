import '../../core/index.dart';
import '../../model/index.dart';
import 'base_data.dart';
import 'data_helper.dart';

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

  DataHelper<T, P, BaseGridSeries>? _helper;

  DataHelper<T, P, BaseGridSeries> get helper {
    _helper ??= DataHelper(this, data);
    return _helper!;
  }

  @override
  void notifySeriesConfigChange() {
    _helper = null;
    super.notifySeriesConfigChange();
  }

  @override
  void notifyUpdateData() {
    _helper = null;
    super.notifyUpdateData();
  }
}
