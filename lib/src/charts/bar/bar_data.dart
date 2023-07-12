import 'package:e_chart/e_chart.dart';
import 'package:e_chart/src/charts/grid/base_data.dart';

class BarGroupData extends BaseGroupData<BarItemData> {

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

  @override
  bool operator ==(Object other) {
    return other is BarGroupData && other.id == id;
  }
}

class BarItemData extends BaseItemData {
  BarItemData(super.x, super.up, super.down);

  @override
  bool operator ==(Object other) {
    return other is BarItemData && other.id == id;
  }

}
