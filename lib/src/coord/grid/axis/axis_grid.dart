import 'package:e_chart/e_chart.dart';

///笛卡尔坐标轴
class GridAxis extends BaseAxis {
  Align2 position;
  double offset;

  GridAxis({this.position = Align2.end,
    this.offset = 8,
    super.alignTicks,
    super.show,
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
