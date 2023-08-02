import 'dart:ui';

import '../../model/index.dart';

abstract class ChartEvent{}

class EventParams {
  ///当前图形元素所属的组件名称，
  ComponentType componentType;

  ///系列类型。值可能为：'line'、'bar'、'pie' 等。
  ///当 componentType 为 'series' 时有意义。
  SeriesType? seriesType;

  ///系列在传入的 option.series 中的 index。当 componentType 为 'series' 时有意义。
  int? seriesIndex;

  ///系列名称。当 componentType 为 'series' 时有意义。
  DynamicText? seriesName;

  ///数据索引
  int dataIndex;

  ///传入的原始数据项
  dynamic data;

  /// sankey、graph 等图表同时含有 nodeData 和 edgeData 两种 data，
  /// dataType 的值会是 'node' 或者 'edge'，表示当前点击在 node 还是 edge 上。
  /// 其他大部分图表中只有一种 data，dataType 无意义。
  DataType dataType;

  ///数据图形的颜色。当 componentType 为 'series' 时有意义。
  Color? color;

  EventParams({
    required this.componentType,
    required this.data,
    required this.dataIndex,
    required this.dataType,
    this.seriesType,
    this.seriesIndex,
    this.seriesName,
    this.color,
  });
}
