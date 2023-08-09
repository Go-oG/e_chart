import 'package:e_chart/e_chart.dart';

class BarGroupData extends StackGroupData<StackItemData> {
  BarGroupData(
    super.data, {
    super.xAxisIndex,
    super.yAxisIndex,
    super.id,
    super.barSize,
    super.barMaxSize,
    super.barMinSize,
    super.stackId,
    super.strategy,
    super.styleIndex,
  });
}
