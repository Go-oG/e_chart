import 'package:e_chart/e_chart.dart';

///数据选中状态发生变化时触发的事件
class SelectChangeEvent extends ChartEvent {
  final List<SelectAction> selectActions;
  final List<UnSelectedAction> unselectActions;
  final List<ToggleSelectAction> toggleActions;

  SelectChangeEvent({
    this.selectActions = const [],
    this.unselectActions = const [],
    this.toggleActions = const [],
  });

  @override
  EventType get eventType => EventType.normal;
}
