import 'package:e_chart/e_chart.dart';

class LineGroupData extends StackGroupData<StackItemData,LineGroupData> {
  bool? smooth;

  LineGroupData(
    super.data, {
    this.smooth,
    super.xAxisIndex,
    super.yAxisIndex,
    super.id,
    super.stackId,
    super.barMaxSize,
    super.barMinSize,
    super.barSize,
  });
}
