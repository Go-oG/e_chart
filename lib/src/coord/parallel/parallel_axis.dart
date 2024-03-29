import '../../component/axis/base_axis.dart';

///平行坐标系坐标轴

class ParallelAxis extends BaseAxis {
  int parallelIndex;
  bool realTime;

  ParallelAxis({
    this.parallelIndex = 0,
    this.realTime = true,
    super.show,
    super.type = AxisType.value,
    super.min,
    super.max,
    super.splitNumber,
    super.start0,
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.inverse,
    super.categoryList,
    super.timeRange,
    super.timeType,
    super.timeFormatFun,
    super.categoryCenter,
    super.axisName,
    super.axisLine,
    super.axisLabel,
    super.splitLine,
    super.minorSplitLine,
    super.splitArea,
    super.axisTick,
    super.minorTick,
    super.axisPointer,
  });
}
