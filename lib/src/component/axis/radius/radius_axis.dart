import '../base_axis.dart';
import '../model/axis_type.dart';

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
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.inverse,
    super.categoryList,
    super.categoryCenter,
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
    super.id,
  });
}
