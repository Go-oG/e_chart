import 'package:e_chart/e_chart.dart';

///平行坐标系选中事件(针对一组数据)
class ParallelSelectedEvent extends ChartEvent {
  final String coordId;
  final String coordViewId;
  final int index;
  final bool selected;

  ParallelSelectedEvent(this.coordId, this.coordViewId, this.index, this.selected);

  @override
  EventType get eventType => EventType.parallelSelected;
}

