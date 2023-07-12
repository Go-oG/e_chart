import '../../../component/axis/axis_style.dart';
import '../../../model/enums/align2.dart';
import 'axis_grid.dart';

class YAxis extends GridAxis {
  YAxis({
    super.alignTicks,
    super.position = Align2.start,
    super.type,
    super.offset,
    super.nameAlign,
    super.nameStyle,
    super.nameGap,
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
    super.axisPointer,
    super.name,
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
