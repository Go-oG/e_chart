import 'base_axis.dart';
import 'axis_type.dart';

///雷达图坐标轴
class RadarAxis extends BaseAxis {
  RadarAxis({
    super.show,
    super.axisName,
    super.min,
    super.max,
    super.splitNumber,
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.timeType,
    super.axisLabel,
    super.axisLine,
    super.alignTicks,
    super.axisPointer,
    super.axisTick,
    super.categoryCenter,
    super.inverse,
    super.splitArea,
    super.splitLine,
    super.id,
  }) : super(type: AxisType.value, categoryList: const [], timeRange: null);
}
