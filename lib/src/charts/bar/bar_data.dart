import 'package:e_chart/e_chart.dart';

class BarGroupData extends StackGroupData<StackItemData> {
  ///控制柱状图的大小（具体的含义取决于布局的方向）
  SNumber? barSize;
  SNumber? barMaxSize;
  SNumber? barMinSize;

  BarGroupData(
    super.data, {
    super.xAxisIndex,
    super.yAxisIndex,
    super.id,
    this.barSize,
    this.barMaxSize,
    this.barMinSize = const SNumber(1, false),
    super.stackId,
    super.strategy,
  });
}
