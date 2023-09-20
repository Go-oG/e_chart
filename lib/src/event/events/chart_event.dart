import '../../core/model/series_type.dart';
import '../../model/index.dart';
import 'chart_event_dispatcher.dart';

abstract class ChartEvent {
  const ChartEvent();

  EventType get eventType;
}

class EventInfo {
  ///当前图形元素所属的组件名称，
  final ComponentType componentType;

  ///系列类型。值可能为：'line'、'bar'、'pie' 等。
  ///当 componentType 为 'series' 时有意义。
  final SeriesType? seriesType;

  ///系列在传入的 option.series 中的 index。当 componentType 为 'series' 时有意义。
  final int? seriesIndex;
  final int? groupIndex;

  ///数据索引
  final int? dataIndex;

  ///传入的原始数据项
  final dynamic data;
  final dynamic node;

  /// sankey、graph 等图表同时含有 nodeData 和 edgeData 两种 data，
  /// dataType 的值会是 'node' 或者 'edge'，表示当前点击在 node 还是 edge 上。
  /// 其他大部分图表中只有一种 data，dataType 无意义。
  final DataType dataType;

  EventInfo({
    required this.componentType,
    required this.data,
    required this.dataIndex,
    required this.dataType,
    required this.node,
    this.groupIndex,
    this.seriesType,
    this.seriesIndex,
  });

  @override
  int get hashCode {
    return Object.hash(componentType, data, dataType, dataIndex, node, groupIndex, seriesIndex, seriesType);
  }

  @override
  bool operator ==(Object other) {
    return other is EventInfo &&
        other.seriesIndex == seriesIndex &&
        other.componentType == componentType &&
        other.data == data &&
        other.dataType == dataType &&
        other.dataIndex == dataIndex &&
        other.node == node &&
        other.groupIndex == groupIndex &&
        other.seriesType == seriesType;
  }

  @override
  String toString() {
    return "componentType:$componentType\n"
        "seriesType:$seriesType seriesIndex:$seriesIndex\n"
        "groupIndex:$groupIndex dataIndex:$dataIndex dataType:$dataType\n"
        "data:$data ";
  }
}
