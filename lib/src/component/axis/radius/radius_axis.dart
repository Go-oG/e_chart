import '../base_axis.dart';

///极坐标-径向轴
class RadiusAxis extends BaseAxis {
  num offsetAngle;

  RadiusAxis({
    this.offsetAngle = 0,
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
    super.categoryCenter,
    super.timeRange,
    super.timeType,
    super.timeFormatFun,
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
