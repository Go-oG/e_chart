import 'package:e_chart/e_chart.dart';

///笛卡尔坐标轴
class GridAxis extends BaseAxis {
  bool alignTicks;
  Align2 position;
  double offset;
  SplitArea? splitArea;
  AxisPointer? axisPointer;

  GridAxis({
    this.alignTicks = false,
    this.position = Align2.end,
    this.offset = 0,
    this.splitArea,
    this.axisPointer,
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
    super.timeRange,
    super.timeSplitType,
    super.silent,
    super.axisLine,
    super.formatFun,
    super.nameAlign,
    super.nameGap,
    super.nameStyle,
  });
}
