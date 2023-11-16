import 'package:e_chart/e_chart.dart';

abstract class ChartEvent {
  const ChartEvent();

  EventType get eventType;

  void dispose() {}
}

class EventInfo {
  ///当前图形元素所属的组件名称，
  final ComponentType componentType;

  ///系列类型。值可能为：'line'、'bar'、'pie' 等。
  ///当 componentType 为 'series' 时有意义。
  final SeriesType? seriesType;

  ///系列在传入的 option.series 中的 index。当 componentType 为 'series' 时有意义。
  final int? seriesIndex;

  ///传入的原始数据项
  final RenderData data;

  EventInfo({
    required this.componentType,
    required this.data,
    this.seriesType,
    this.seriesIndex,
  });

  @override
  int get hashCode {
    return Object.hash(componentType, data, seriesIndex, seriesType);
  }

  @override
  bool operator ==(Object other) {
    return other is EventInfo && other.seriesIndex == seriesIndex && other.componentType == componentType && other.data == data && other.seriesType == seriesType;
  }

  @override
  String toString() {
    return "componentType:$componentType\n"
        "seriesType:$seriesType seriesIndex:$seriesIndex\n"
        "data:$data ";
  }
}
