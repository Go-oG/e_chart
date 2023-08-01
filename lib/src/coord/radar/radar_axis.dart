import '../../component/axis/base_axis.dart';
///雷达图坐标轴
class RadarAxis extends BaseAxis {
  RadarAxis({
    super.show,
    super.axisName,
    super.min,
    super.max,
    super.splitNumber,
    super.start0,
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.timeFormatFun,
    super.timeType,
    super.axisLabel,
    super.axisLine,
    super.alignTicks,
    super.axisPointer,
    super.axisTick,
    super.categoryCenter,
    super.inverse,
    super.minorSplitLine,
    super.minorTick,
    super.splitArea,
    super.splitLine,
  }) : super(type: AxisType.value, categoryList: const [], timeRange: null);
}
