import '../../model/enums/align2.dart';
import '../../component/axis/grid/axis_grid.dart';

class XAxis extends GridAxis {
  XAxis({
    super.alignTicks,
    super.position = Align2.end,
    super.type,
    super.offset,
    super.inverse,
    super.min,
    super.max,
    super.splitNumber,
    super.minInterval,
    super.maxInterval,
    super.interval,
    super.logBase,
    super.categoryList,
    super.categoryCenter,
    super.show,
    super.timeRange,
    super.timeType,
    super.axisName,
    super.axisLine,
    super.axisLabel,
    super.splitLine,
    super.splitArea,
    super.axisTick,
    super.axisPointer,
    super.id,
  });
}
