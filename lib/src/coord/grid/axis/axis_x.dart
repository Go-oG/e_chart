import '../../../model/enums/align2.dart';
import 'axis_grid.dart';

class XAxis extends GridAxis {
  XAxis({
    super.alignTicks,
    super.position = Align2.end,
    super.type,
    super.offset,
    super.inverse,
    super.min,
    super.max,
    super.start0,
    super.splitNumber,
    super.minInterval,
    super.maxInterval,
    super.interval,
    super.logBase,
    super.silent,
    super.axisStyle,
    super.categoryList,
    super.categoryCenter,
    super.axisPointer,
    super.axisName,
    super.show,
    super.timeRange,
    super.timeType,
    super.timeFormatFun,
  });
}
