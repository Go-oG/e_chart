
import 'package:e_chart/e_chart.dart';

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
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.categoryList,
    super.timeRange,
    super.timeType,
    super.axisName,
    super.axisLine,
    super.axisLabel,
    super.splitLine,
    super.splitArea,
    super.axisTick,
    super.axisPointer,
    super.alignTicks,
    super.categoryCenter = false,
    super.id,
  }) : super(inverse: false);
}
