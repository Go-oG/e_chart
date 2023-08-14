import 'dart:ui';

import '../../model/index.dart';

abstract class ChartEvent {}

class EventParams {
  ///当前图形元素所属的组件名称，
  ComponentType componentType;

  ///系列类型。值可能为：'line'、'bar'、'pie' 等。
  ///当 componentType 为 'series' 时有意义。
  SeriesType? seriesType;

  ///系列在传入的 option.series 中的 index。当 componentType 为 'series' 时有意义。
  int? seriesIndex;
  int? groupIndex;

  ///数据索引
  int? dataIndex;

  ///传入的原始数据项
  dynamic data;

  /// sankey、graph 等图表同时含有 nodeData 和 edgeData 两种 data，
  /// dataType 的值会是 'node' 或者 'edge'，表示当前点击在 node 还是 edge 上。
  /// 其他大部分图表中只有一种 data，dataType 无意义。
  DataType dataType;

  EventParams({
    required this.componentType,
    required this.data,
    required this.dataIndex,
    required this.dataType,
    this.groupIndex,
    this.seriesType,
    this.seriesIndex,
  });

  @override
  String toString() {
    return "componentType:$componentType\n"
        "seriesType:$seriesType seriesIndex:$seriesIndex\n"
        "groupIndex:$groupIndex dataIndex:$dataIndex dataType:$dataType\n"
        "data:$data ";
  }
}
