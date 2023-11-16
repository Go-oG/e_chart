import 'package:e_chart/e_chart.dart';

class BarGroupData extends StackGroupData<StackItemData, BarGroupData> {
  BarGroupData(
    super.data, {
    super.domainAxis,
    super.valueAxis,
    super.id,
    super.name,
    super.barSize,
    super.barMaxSize,
    super.barMinSize,
    super.stackId,
    super.styleIndex,
    super.stackUsePercent,
  });
}
