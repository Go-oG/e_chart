import 'package:e_chart/e_chart.dart';

///笛卡尔坐标轴
class GridAxis extends BaseAxis {
  Align2 position;
  double offset;
  AxisPointer? axisPointer;

  GridAxis({
    this.position = Align2.end,
    this.offset = 8,
    this.axisPointer,
    super.alignTicks,
    super.show,
    super.name,
    super.type,
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
    super.silent,
    super.axisStyle,
    super.nameAlign,
    super.nameGap,
    super.nameStyle,
    super.timeFormatFun
  });
}
