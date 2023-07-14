import 'package:e_chart/e_chart.dart';

import '../grid/base_data.dart';

class LineGroupData extends BaseGroupData<LineItemData> {
  LineGroupData(
    super.data, {
    super.xAxisIndex,
    super.yAxisIndex,
    String? id,
    super.stackId,
    super.strategy,
  });
}

class LineItemData extends BaseItemData {
  LineItemData(DynamicData x, num value) : super(x, value, 0);

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return other is LineItemData && other.id == id;
  }
}
