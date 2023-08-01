
import 'package:e_chart/e_chart.dart';

class YAxis extends GridAxis {
  YAxis({
    super.alignTicks,
    super.position = Align2.start,
    super.type,
    super.offset,
    super.inverse,
    super.min,
    super.max,
    super.start0,
    super.splitNumber,
    super.minInterval,
    super.maxInterval,
    super.interval,
    super.logBase,
    super.silent,
    AxisStyle? axisStyle,
    super.categoryList,
    super.categoryCenter,
    super.axisPointer,
    super.axisName,
    super.show,
    super.timeRange,
    super.timeType,
    super.timeFormatFun,
  }) {
    if (axisStyle != null) {
      this.axisStyle = axisStyle;
    } else {
      this.axisStyle.axisTick.tick?.inside = false;
      this.axisStyle.axisLabel.inside = true;
    }
  }
}
