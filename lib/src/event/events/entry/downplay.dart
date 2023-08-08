import '../chart_event.dart';

///取消高亮事件
class DownplayEvent extends ChartEvent {
  final List<int> seriesIndex;
  final List<String> seriesId;

  final List<int> dataIndex;
  final List<String> dataId;

  DownplayEvent({
    this.seriesIndex = const [],
    this.seriesId = const [],
    this.dataIndex = const [],
    this.dataId = const [],
  });
}
