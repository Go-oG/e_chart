import '../../component/axis/base_axis.dart';
import '../../model/enums/align2.dart';
///极坐标-径向轴
class RadiusAxis extends BaseAxis {
  Align2 nameLocation;
  num offsetAngle;
  num nameRotate;

  RadiusAxis({
    this.nameLocation = Align2.end,
    this.offsetAngle = 0,
    this.nameRotate = 0,
    super.show,
    super.name,
    super.nameGap = 15,
    super.nameAlign,
    super.nameStyle,
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
    super.timeSplitType,
    super.silent,
    super.axisLine,
    super.formatFun,
    super.timeFormatFun,
  });
}
