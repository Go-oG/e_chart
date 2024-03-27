import 'package:e_chart/e_chart.dart';

class YAxis extends GridAxis {
  YAxis({
    super.show,
    super.alignTicks,
    super.position = Align2.start,
    super.type,
    super.offset,
    super.inverse,
    super.min,
    super.max,
    super.splitNumber,
    super.minInterval,
    super.maxInterval,
    super.logBase,
    super.categoryList,
    super.categoryCenter,
    super.timeRange,
    super.timeType,
    super.interval,
    super.axisName,
    super.axisLine,
    AxisLabel? axisLabel,
    super.splitLine,
    super.splitArea,
    AxisTick? axisTick,
    super.axisPointer,
    super.id,
  }) {
    if (axisLabel == null) {
      this.axisLabel.inside = true;
    } else {
      this.axisLabel = axisLabel;
    }
    if (axisTick != null) {
      this.axisTick = axisTick;
    } else {
      this.axisTick.inside = true;
    }
  }
}