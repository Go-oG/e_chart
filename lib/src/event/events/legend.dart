import 'package:e_chart/e_chart.dart';

class LegendScrollEvent extends ChartEvent {
  LegendScrollEvent();

  @override
  EventType get eventType => EventType.legendScroll;
}

///图例反选后的事件
class LegendInverseSelectEvent extends ChartEvent {
  final List<LegendItem> selectedList;
  final List<LegendItem> unselectedList;

  const LegendInverseSelectEvent(this.selectedList, this.unselectedList);

  @override
  EventType get eventType => EventType.legendInverseSelect;
}

///图例全选事件
class LegendSelectAllEvent extends ChartEvent {
  final List<LegendItem> selectedList;

  const LegendSelectAllEvent(this.selectedList);

  @override
  EventType get eventType => EventType.legendSelectAll;
}

///图例取消选择
class LegendUnSelectedEvent extends ChartEvent{
  final List<LegendItem> unselectList;

  LegendUnSelectedEvent(this.unselectList);

  @override
  EventType get eventType => EventType.legendUnSelect;
}

///图例选择状态变更
class LegendSelectChangeEvent extends ChartEvent {
  final LegendItem legendItem;

  LegendSelectChangeEvent(this.legendItem);

  @override
  EventType get eventType => EventType.legendSelectChanged;
}
