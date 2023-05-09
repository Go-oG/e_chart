
import '../../component/axis/axis_label.dart';
import '../../component/axis/axis_pointer.dart';
import '../../component/axis/base_axis.dart';
import '../../component/axis/split_area.dart';
import '../../component/axis/split_line.dart';
import '../../component/tick/main_tick.dart';
import '../../component/tick/minor_tick.dart';
import '../../model/enums/align2.dart';

///笛卡尔坐标轴
class GridAxis extends BaseAxis {
  final bool alignTicks;
  final Align2 position;
  final double offset;
  final MainTick axisTick;
  final MinorTick minorTick;
  final AxisLabel axisLabel;
  final SplitLine splitLine;
  final MinorSplitLine minorSplitLine;
  final SplitArea splitArea;
  final AxisPointer axisPointer;

  const GridAxis({
    this.alignTicks = false,
    this.position = Align2.end,
    this.offset = 0,
    this.axisTick = const MainTick(),
    this.minorTick = const MinorTick(),
    this.axisLabel = const AxisLabel(),
    this.splitLine = const SplitLine(),
    this.minorSplitLine = const MinorSplitLine(),
    this.splitArea = const SplitArea(),
    this.axisPointer = const AxisPointer(),
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
