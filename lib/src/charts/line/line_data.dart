import 'package:e_chart/e_chart.dart';

class LineGroupData extends BaseGroupData<LineItemData> {
  bool? smooth;

  LineGroupData(
    super.data, {
    this.smooth,
    super.xAxisIndex,
    super.yAxisIndex,
    String? id,
    super.stackId,
    super.strategy,
  });
}

class LineItemData extends BaseItemData {
  LineItemData(DynamicData x, num value, {super.id}) : super(x, value, 0);

  @override
  String toString() {
    return "X:${x} v:${up.toStringAsFixed(2)}";
  }
}
