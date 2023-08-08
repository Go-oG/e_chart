import '../base_axis.dart';

///极坐标-角度轴
class AngleAxis extends BaseAxis {
  /// 起始刻度的角度，默认为90度(圆心的正上方为0度)
  num offsetAngle;

  ///是否顺时针
  bool clockwise;

  AngleAxis({
    this.offsetAngle = 0,
    this.clockwise = true,
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
    super.categoryList,
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
    super.alignTicks,
    super.categoryCenter,
  }) : super(inverse: false);
}
