import '../../component/axis/base_axis.dart';

class RadarAxis extends BaseAxis {
  RadarAxis({
    super.show,
    super.name,
    super.nameStyle,
    super.nameGap,
    super.min,
    super.max,
    super.splitNumber,
    super.start0,
    super.logBase,
    super.interval,
    super.maxInterval,
    super.minInterval,
    super.silent,
    super.axisStyle,
    super.nameAlign,
    super.timeFormatFun,
    super.timeType,
  }) : super(type: AxisType.value, categoryList: const [], timeRange: null);
}
