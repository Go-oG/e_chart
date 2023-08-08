import '../chart_event.dart';

///高亮事件
class HighlightEvent extends ChartEvent {
  final List<int> seriesIndex;
  final List<String> seriesId;

  final List<int> dataIndex;
  final List<String> dataId;

  HighlightEvent({
    this.seriesIndex = const [],
    this.seriesId = const [],
    this.dataIndex = const [],
    this.dataId = const [],
  });

}
