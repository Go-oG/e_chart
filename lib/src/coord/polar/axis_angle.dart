
import '../../component/axis/axis_pointer.dart';
import '../../component/axis/base_axis.dart';


///极坐标-角度轴
class AngleAxis extends BaseAxis {
  /// 起始刻度的角度，默认为90度(圆心的正上方为0度)
  num offsetAngle;
  num radiusOffset;

  ///是否顺时针
  bool clockwise;
  AxisPointer? axisPointer;

  AngleAxis({
    this.offsetAngle = 0,
    this.radiusOffset = 0,
    this.clockwise = true,
    this.axisPointer,
    super.show,
    super.name,
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
    super.silent,
    super.axisStyle,
    super.nameAlign,
    super.nameGap,
    super.nameStyle,
    super.timeFormatFun,
  }) : super(inverse: false);
}
